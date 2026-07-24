#include "lstrrr.h"
#include <string.h>
#include <stdio.h>
#include <limits.h>

/* -------------------------------------------------------------------------- */
/* shared helpers (declared in lstrrr.h)                                      */
/* -------------------------------------------------------------------------- */

int is_data_frame(SEXP x)
{
    SEXP cls = Rf_getAttrib(x, R_ClassSymbol);
    if (cls == R_NilValue) return 0;
    for (R_xlen_t i = 0; i < XLENGTH(cls); i++)
    {
        if (strcmp(CHAR(STRING_ELT(cls, i)), "data.frame") == 0)
        {
            return 1;
        }
    }
    return 0;
}

int is_plain_list(SEXP x)
{
    return TYPEOF(x) == VECSXP && !is_data_frame(x);
}

SEXP shallow_copy_list(SEXP x)
{
    R_xlen_t n = is_plain_list(x) ? XLENGTH(x) : 0;
    SEXP out = PROTECT(Rf_allocVector(VECSXP, n));
    for (R_xlen_t i = 0; i < n; i++)
    {
        SET_VECTOR_ELT(out, i, VECTOR_ELT(x, i));
    }
    if (is_plain_list(x))
    {
        SEXP names = Rf_getAttrib(x, R_NamesSymbol);
        if (names != R_NilValue)
        {
            Rf_setAttrib(out, R_NamesSymbol, names);
        }
    }
    SEXP cls = Rf_getAttrib(x, R_ClassSymbol);
    if (cls != R_NilValue)
    {
        Rf_setAttrib(out, R_ClassSymbol, cls);
    }
    UNPROTECT(1);
    return out;
}

/* -------------------------------------------------------------------------- */
/* local helpers                                                              */
/* -------------------------------------------------------------------------- */

static int path_is_string(SEXP path)
{
    return TYPEOF(path) == STRSXP;
}

static int path_is_integerish(SEXP path)
{
    return TYPEOF(path) == INTSXP || TYPEOF(path) == REALSXP;
}

static R_xlen_t find_name_in_list(SEXP x, SEXP key)
{
    SEXP names = Rf_getAttrib(x, R_NamesSymbol);
    if (names == R_NilValue || key == NA_STRING) return -1;
    const char *k = CHAR(key);
    for (R_xlen_t i = 0; i < XLENGTH(x); i++)
    {
        SEXP nm = STRING_ELT(names, i);
        if (nm == NA_STRING) continue;
        if (strcmp(CHAR(nm), k) == 0) return i;
    }
    return -1;
}

static SEXP get_by_char(SEXP x, SEXP path, SEXP def)
{
    SEXP cur = x;
    for (R_xlen_t i = 0; i < XLENGTH(path); i++)
    {
        if (!is_plain_list(cur)) return def;
        R_xlen_t pos = find_name_in_list(cur, STRING_ELT(path, i));
        if (pos < 0) return def;
        cur = VECTOR_ELT(cur, pos);
    }
    return cur;
}

static SEXP get_by_int(SEXP x, SEXP path, SEXP def)
{
    SEXP cur = x;
    for (R_xlen_t i = 0; i < XLENGTH(path); i++)
    {
        if (!is_plain_list(cur)) return def;
        int idx = TYPEOF(path) == INTSXP ? INTEGER(path)[i] : (int) REAL(path)[i];
        if (idx == NA_INTEGER || idx < 1 || idx > XLENGTH(cur))
        {
            return def;
        }
        cur = VECTOR_ELT(cur, idx - 1);
    }
    return cur;
}

SEXP lstrrr_c_list_get(SEXP x, SEXP path, SEXP def)
{
    if (path == R_NilValue || XLENGTH(path) == 0) return x;
    if (path_is_string(path)) return get_by_char(x, path, def);
    if (path_is_integerish(path)) return get_by_int(x, path, def);
    Rf_error("`path` must be character, integer, or numeric.");
    return R_NilValue;
}

SEXP lstrrr_c_list_has(SEXP x, SEXP path)
{
    SEXP sentinel = PROTECT(Rf_allocVector(VECSXP, 0));
    SEXP res = lstrrr_c_list_get(x, path, sentinel);
    int ok = res != sentinel;
    UNPROTECT(1);
    return Rf_ScalarLogical(ok);
}

static int depth_rec(SEXP x)
{
    if (!is_plain_list(x) || XLENGTH(x) == 0)
    {
        return 0;
    }
    int max_depth = 0;
    for (R_xlen_t i = 0; i < XLENGTH(x); i++)
    {
        int d = depth_rec(VECTOR_ELT(x, i));
        if (d > max_depth)
        {
            max_depth = d;
        }
    }
    return max_depth + 1;
}

SEXP lstrrr_c_list_depth(SEXP x)
{
    return Rf_ScalarInteger(depth_rec(x));
}

typedef struct
{
    SEXP data;
    R_xlen_t size;
    R_xlen_t capacity;
    int protect_count;
} path_builder;

static void pb_init(path_builder *b)
{
    b->capacity = 128;
    b->size = 0;
    b->data = PROTECT(Rf_allocVector(VECSXP, b->capacity));
    b->protect_count = 1;
}

static void pb_grow(path_builder *b)
{
    R_xlen_t newcap = b->capacity * 2;
    SEXP newdata = PROTECT(Rf_allocVector(VECSXP, newcap));
    for (R_xlen_t i = 0; i < b->size; i++)
    {
        SET_VECTOR_ELT(newdata, i, VECTOR_ELT(b->data, i));
    }
    b->data = newdata;
    b->capacity = newcap;
    b->protect_count++;
}

static SEXP path_push(SEXP path, SEXP key)
{
    R_xlen_t n = XLENGTH(path);
    SEXP out = PROTECT(Rf_allocVector(STRSXP, n + 1));
    for (R_xlen_t i = 0; i < n; i++)
    {
        SET_STRING_ELT(out, i, STRING_ELT(path, i));
    }
    SET_STRING_ELT(out, n, key);
    UNPROTECT(1);
    return out;
}

static SEXP index_key(R_xlen_t i)
{
    char buf[64];
    snprintf(buf, sizeof(buf), "%lld", (long long) i + 1);
    return Rf_mkChar(buf);
}

static SEXP child_key(SEXP names, R_xlen_t i)
{
    if (
        names != R_NilValue &&
        i < XLENGTH(names) &&
        STRING_ELT(names, i) != NA_STRING &&
        CHAR(STRING_ELT(names, i))[0] != '\0'
    )
    {
        return STRING_ELT(names, i);
    }
    return index_key(i);
}

static void path_walk(SEXP x, SEXP path, path_builder *b)
{
    if (is_plain_list(x))
    {
        SEXP names = Rf_getAttrib(x, R_NamesSymbol);
        for (R_xlen_t i = 0; i < XLENGTH(x); i++)
        {
            SEXP key = child_key(names, i);
            SEXP new_path = PROTECT(path_push(path, key));
            path_walk(VECTOR_ELT(x, i), new_path, b);
            UNPROTECT(1);
        }
    }
    else
    {
        if (b->size >= b->capacity)
        {
            pb_grow(b);
        }
        SET_VECTOR_ELT(b->data, b->size, path);
        b->size++;
    }
}

SEXP lstrrr_c_list_path(SEXP x)
{
    path_builder b;
    pb_init(&b);
    SEXP root = PROTECT(Rf_allocVector(STRSXP, 0));
    path_walk(x, root, &b);
    SEXP out = PROTECT(Rf_allocVector(VECSXP, b.size));
    for (R_xlen_t i = 0; i < b.size; i++)
    {
        SET_VECTOR_ELT(out, i, VECTOR_ELT(b.data, i));
    }
    UNPROTECT(b.protect_count + 2);
    return out;
}

static void join_path(SEXP path, const char *sep, char *buf, size_t buflen)
{
    buf[0] = '\0';
    for (R_xlen_t i = 0; i < XLENGTH(path); i++)
    {
        if (i > 0)
        {
            strncat(buf, sep, buflen - strlen(buf) - 1);
        }
        strncat(buf, CHAR(STRING_ELT(path, i)), buflen - strlen(buf) - 1);
    }
}

typedef struct
{
    SEXP values;
    SEXP names;
    R_xlen_t size;
    R_xlen_t capacity;
    int protect_count;
} flat_builder;

static void fb_init(flat_builder *b)
{
    b->capacity = 128;
    b->size = 0;
    b->values = PROTECT(Rf_allocVector(VECSXP, b->capacity));
    b->names = PROTECT(Rf_allocVector(STRSXP, b->capacity));
    b->protect_count = 2;
}

static void fb_grow(flat_builder *b)
{
    R_xlen_t newcap = b->capacity * 2;
    SEXP newvalues = PROTECT(Rf_allocVector(VECSXP, newcap));
    SEXP newnames = PROTECT(Rf_allocVector(STRSXP, newcap));
    for (R_xlen_t i = 0; i < b->size; i++)
    {
        SET_VECTOR_ELT(newvalues, i, VECTOR_ELT(b->values, i));
        SET_STRING_ELT(newnames, i, STRING_ELT(b->names, i));
    }
    b->values = newvalues;
    b->names = newnames;
    b->capacity = newcap;
    b->protect_count += 2;
}

static void flatten_walk(SEXP x, SEXP path, const char *sep, flat_builder *b)
{
    if (is_plain_list(x))
    {
        SEXP names = Rf_getAttrib(x, R_NamesSymbol);
        for (R_xlen_t i = 0; i < XLENGTH(x); i++)
        {
            SEXP key = child_key(names, i);
            SEXP new_path = PROTECT(path_push(path, key));
            flatten_walk(VECTOR_ELT(x, i), new_path, sep, b);
            UNPROTECT(1);
        }
    }
    else
    {
        if (b->size >= b->capacity)
        {
            fb_grow(b);
        }
        char name[4096];
        join_path(path, sep, name, sizeof(name));
        SET_VECTOR_ELT(b->values, b->size, x);
        SET_STRING_ELT(b->names, b->size, Rf_mkChar(name));
        b->size++;
    }
}

SEXP lstrrr_c_list_flatten(SEXP x, SEXP sep_)
{
    if (TYPEOF(sep_) != STRSXP || XLENGTH(sep_) != 1)
    {
        Rf_error("`sep` must be a string.");
    }
    const char *sep = CHAR(STRING_ELT(sep_, 0));
    flat_builder b;
    fb_init(&b);
    SEXP root = PROTECT(Rf_allocVector(STRSXP, 0));
    flatten_walk(x, root, sep, &b);
    SEXP out = PROTECT(Rf_allocVector(VECSXP, b.size));
    SEXP nms = PROTECT(Rf_allocVector(STRSXP, b.size));
    for (R_xlen_t i = 0; i < b.size; i++)
    {
        SET_VECTOR_ELT(out, i, VECTOR_ELT(b.values, i));
        SET_STRING_ELT(nms, i, STRING_ELT(b.names, i));
    }
    Rf_setAttrib(out, R_NamesSymbol, nms);
    UNPROTECT(b.protect_count + 3);
    return out;
}


static SEXP append_to_list(SEXP x, SEXP key, SEXP value)
{
    R_xlen_t n = XLENGTH(x);
    SEXP out = PROTECT(Rf_allocVector(VECSXP, n + 1));
    SEXP nms = PROTECT(Rf_allocVector(STRSXP, n + 1));
    SEXP old_names = Rf_getAttrib(x, R_NamesSymbol);
    for (R_xlen_t i = 0; i < n; i++)
    {
        SET_VECTOR_ELT(out, i, VECTOR_ELT(x, i));
        if (old_names != R_NilValue && i < XLENGTH(old_names))
        {
            SET_STRING_ELT(nms, i, STRING_ELT(old_names, i));
        }
        else
        {
            SET_STRING_ELT(nms, i, Rf_mkChar(""));
        }
    }
    SET_VECTOR_ELT(out, n, value);
    SET_STRING_ELT(nms, n, key);
    Rf_setAttrib(out, R_NamesSymbol, nms);
    UNPROTECT(2);
    return out;
}

static SEXP set_char_rec(SEXP x, SEXP path, R_xlen_t pos, SEXP value)
{
    SEXP key = STRING_ELT(path, pos);
    SEXP out = PROTECT(shallow_copy_list(x));
    R_xlen_t idx = find_name_in_list(out, key);
    if (idx < 0)
    {
        SEXP child = R_NilValue;
        if (pos == XLENGTH(path) - 1)
        {
            child = value;
        }
        else
        {
            child = PROTECT(set_char_rec(R_NilValue, path, pos + 1, value));
        }
        SEXP grown = PROTECT(append_to_list(out, key, child));
        if (pos != XLENGTH(path) - 1)
        {
            UNPROTECT(1);
        }
        UNPROTECT(2);
        return grown;
    }
    if (pos == XLENGTH(path) - 1)
    {
        SET_VECTOR_ELT(out, idx, value);
    }
    else
    {
        SEXP child = VECTOR_ELT(out, idx);
        SEXP new_child = PROTECT(set_char_rec(child, path, pos + 1, value));
        SET_VECTOR_ELT(out, idx, new_child);
        UNPROTECT(1);
    }
    UNPROTECT(1);
    return out;
}

static SEXP set_int_rec(SEXP x, SEXP path, R_xlen_t pos, SEXP value)
{
    int idx1 = TYPEOF(path) == INTSXP ? INTEGER(path)[pos] : (int) REAL(path)[pos];
    if (idx1 == NA_INTEGER || idx1 < 1)
    {
        Rf_error("Invalid numeric path.");
    }
    R_xlen_t idx = idx1 - 1;
    R_xlen_t old_n = is_plain_list(x) ? XLENGTH(x) : 0;
    R_xlen_t new_n = idx + 1 > old_n ? idx + 1 : old_n;
    SEXP out = PROTECT(Rf_allocVector(VECSXP, new_n));
    for (R_xlen_t i = 0; i < old_n; i++)
    {
        SET_VECTOR_ELT(out, i, VECTOR_ELT(x, i));
    }
    if (pos == XLENGTH(path) - 1)
    {
        SET_VECTOR_ELT(out, idx, value);
    }
    else
    {
        SEXP child = VECTOR_ELT(out, idx);
        SEXP new_child = PROTECT(set_int_rec(child, path, pos + 1, value));
        SET_VECTOR_ELT(out, idx, new_child);
        UNPROTECT(1);
    }
    UNPROTECT(1);
    return out;
}

SEXP lstrrr_c_list_set(SEXP x, SEXP path, SEXP value)
{
    if (path == R_NilValue || XLENGTH(path) == 0) return value;
    if (path_is_string(path)) return set_char_rec(x, path, 0, value);
    if (path_is_integerish(path)) return set_int_rec(x, path, 0, value);
    Rf_error("`path` must be character, integer, or numeric.");
    return R_NilValue;
}

static SEXP remove_list_at(SEXP x, R_xlen_t idx)
{
    R_xlen_t n = XLENGTH(x);
    if (idx < 0 || idx >= n)
    {
        return x;
    }
    SEXP out = PROTECT(Rf_allocVector(VECSXP, n - 1));
    SEXP old_names = Rf_getAttrib(x, R_NamesSymbol);
    SEXP nms = R_NilValue;
    int has_names = old_names != R_NilValue;
    if (has_names)
    {
        nms = PROTECT(Rf_allocVector(STRSXP, n - 1));
    }
    R_xlen_t j = 0;
    for (R_xlen_t i = 0; i < n; i++)
    {
        if (i == idx) continue;
        SET_VECTOR_ELT(out, j, VECTOR_ELT(x, i));
        if (has_names)
        {
            SET_STRING_ELT(nms, j, STRING_ELT(old_names, i));
        }
        j++;
    }
    if (has_names)
    {
        Rf_setAttrib(out, R_NamesSymbol, nms);
        UNPROTECT(1);
    }
    UNPROTECT(1);
    return out;
}

static SEXP delete_char_rec(SEXP x, SEXP path, R_xlen_t pos)
{
    if (!is_plain_list(x)) return x;
    R_xlen_t idx = find_name_in_list(x, STRING_ELT(path, pos));
    if (idx < 0) return x;
    if (pos == XLENGTH(path) - 1)
    {
        return remove_list_at(x, idx);
    }
    SEXP out = PROTECT(shallow_copy_list(x));
    SEXP child = VECTOR_ELT(out, idx);
    SEXP new_child = PROTECT(delete_char_rec(child, path, pos + 1));
    SET_VECTOR_ELT(out, idx, new_child);
    UNPROTECT(2);
    return out;
}

static SEXP delete_int_rec(SEXP x, SEXP path, R_xlen_t pos)
{
    if (!is_plain_list(x)) return x;
    int idx1 = TYPEOF(path) == INTSXP ? INTEGER(path)[pos] : (int) REAL(path)[pos];
    if (idx1 == NA_INTEGER || idx1 < 1 || idx1 > XLENGTH(x))
    {
        return x;
    }
    R_xlen_t idx = idx1 - 1;
    if (pos == XLENGTH(path) - 1)
    {
        return remove_list_at(x, idx);
    }
    SEXP out = PROTECT(shallow_copy_list(x));
    SEXP child = VECTOR_ELT(out, idx);
    SEXP new_child = PROTECT(delete_int_rec(child, path, pos + 1));
    SET_VECTOR_ELT(out, idx, new_child);
    UNPROTECT(2);
    return out;
}

SEXP lstrrr_c_list_delete(SEXP x, SEXP path)
{
    if (path == R_NilValue || XLENGTH(path) == 0) return x;
    if (path_is_string(path)) return delete_char_rec(x, path, 0);
    if (path_is_integerish(path)) return delete_int_rec(x, path, 0);
    Rf_error("`path` must be character, integer, or numeric.");
    return R_NilValue;
}

