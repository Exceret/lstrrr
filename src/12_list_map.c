#include "lstrrr.h"
#include <R_ext/Rdynload.h>
#include <R_ext/Print.h>
#include <R_ext/Utils.h>
#include <cli/progress.h>

#include <string.h>
#include <limits.h>
#include <stdio.h>

static R_xlen_t nleaf_rec(SEXP x)
{
    if (!is_plain_list(x))
    {
        return 1;
    }
    R_xlen_t n = XLENGTH(x);
    if (n == 0)
    {
        return 0;
    }
    R_xlen_t total = 0;
    for (R_xlen_t i = 0; i < n; i++)
    {
        total += nleaf_rec(VECTOR_ELT(x, i));
    }
    return total;
}

// list_nleaf
SEXP lstrrr_c_list_nleaf(SEXP x)
{
    R_xlen_t n = nleaf_rec(x);
    if (n <= INT_MAX)
    {
        return Rf_ScalarInteger((int) n);
    }
    return Rf_ScalarReal((double) n);
}

/* -------------------------------------------------------------------------- */
/* cli progress                                                               */
/* -------------------------------------------------------------------------- */

typedef struct
{
    int enabled;
    SEXP bar;
    R_xlen_t total;
    R_xlen_t current;
    R_xlen_t seen;
    int protect_count;
} progress_t;

static int progress_enabled(SEXP progress)
{
    if (TYPEOF(progress) == LGLSXP &&
            XLENGTH(progress) >= 1 &&
            LOGICAL(progress)[0] == TRUE)
    {
        return 1;
    }
    if (TYPEOF(progress) == STRSXP &&
            XLENGTH(progress) == 1 &&
            STRING_ELT(progress, 0) != NA_STRING)
    {
        return 1;
    }
    if (TYPEOF(progress) == VECSXP)
    {
        return 1;
    }
    return 0;
}

static int chr_nonempty(SEXP x)
{
    return x != NA_STRING && strlen(CHAR(x)) > 0;
}

static int named_list_has(SEXP x, const char *key)
{
    if (TYPEOF(x) != VECSXP)
    {
        return 0;
    }
    SEXP nms = Rf_getAttrib(x, R_NamesSymbol);
    if (nms == R_NilValue)
    {
        return 0;
    }
    for (R_xlen_t i = 0; i < XLENGTH(x); i++)
    {
        SEXP nm = STRING_ELT(nms, i);
        if (nm == NA_STRING)
        {
            continue;
        }
        if (strcmp(CHAR(nm), key) == 0)
        {
            return 1;
        }
    }
    return 0;
}

static R_xlen_t named_list_count_named(SEXP x)
{
    if (TYPEOF(x) != VECSXP)
    {
        return 0;
    }
    SEXP nms = Rf_getAttrib(x, R_NamesSymbol);
    if (nms == R_NilValue)
    {
        return 0;
    }
    R_xlen_t total = 0;
    for (R_xlen_t i = 0; i < XLENGTH(x); i++)
    {
        SEXP nm = STRING_ELT(nms, i);
        if (nm != NA_STRING && strlen(CHAR(nm)) > 0)
        {
            total++;
        }
    }
    return total;
}

static SEXP progress_make_config(SEXP progress, const char *default_name)
{
    int is_config = TYPEOF(progress) == VECSXP;
    int has_user_name = is_config && named_list_has(progress, "name");
    int has_user_type = is_config && named_list_has(progress, "type");
    int has_user_clear = is_config && named_list_has(progress, "clear");
    int has_user_auto = is_config && named_list_has(progress, "auto_terminate");
    int add_name = 0;
    if (!is_config &&
            TYPEOF(progress) == STRSXP &&
            XLENGTH(progress) == 1 &&
            chr_nonempty(STRING_ELT(progress, 0)))
    {
        add_name = 1;
    }
    else if (!has_user_name &&
             default_name != NULL &&
             strlen(default_name) > 0)
    {
        add_name = 1;
    }
    int add_type = !has_user_type;
    int add_clear = !has_user_clear;
    int add_auto = !has_user_auto;
    R_xlen_t user_n = is_config ? named_list_count_named(progress) : 0;
    R_xlen_t n = user_n + add_name + add_type + add_clear + add_auto;
    SEXP config = PROTECT(Rf_allocVector(VECSXP, n));
    SEXP nms = PROTECT(Rf_allocVector(STRSXP, n));
    R_xlen_t j = 0;
    if (is_config)
    {
        SEXP user_names = Rf_getAttrib(progress, R_NamesSymbol);
        if (user_names != R_NilValue)
        {
            for (R_xlen_t i = 0; i < XLENGTH(progress); i++)
            {
                SEXP nm = STRING_ELT(user_names, i);
                if (nm == NA_STRING || strlen(CHAR(nm)) == 0)
                {
                    continue;
                }
                SET_VECTOR_ELT(config, j, VECTOR_ELT(progress, i));
                SET_STRING_ELT(nms, j, nm);
                j++;
            }
        }
    }
    if (add_name)
    {
        if (!is_config &&
                TYPEOF(progress) == STRSXP &&
                XLENGTH(progress) == 1 &&
                chr_nonempty(STRING_ELT(progress, 0)))
        {
            SET_VECTOR_ELT(config, j, Rf_ScalarString(STRING_ELT(progress, 0)));
        }
        else
        {
            SET_VECTOR_ELT(config, j, Rf_mkString(default_name));
        }
        SET_STRING_ELT(nms, j, Rf_mkChar("name"));
        j++;
    }
    if (add_type)
    {
        SET_VECTOR_ELT(config, j, Rf_mkString("iterator"));
        SET_STRING_ELT(nms, j, Rf_mkChar("type"));
        j++;
    }
    if (add_clear)
    {
        SET_VECTOR_ELT(config, j, Rf_ScalarLogical(1));
        SET_STRING_ELT(nms, j, Rf_mkChar("clear"));
        j++;
    }
    if (add_auto)
    {
        SET_VECTOR_ELT(config, j, Rf_ScalarLogical(0));
        SET_STRING_ELT(nms, j, Rf_mkChar("auto_terminate"));
        j++;
    }
    Rf_setAttrib(config, R_NamesSymbol, nms);
    UNPROTECT(2);
    return config;
}

static void progress_init(
    progress_t *pb,
    SEXP progress,
    R_xlen_t total,
    const char *default_name
)
{
    pb->enabled = progress_enabled(progress) && total > 0;
    pb->bar = R_NilValue;
    pb->total = total;
    pb->current = 0;
    pb->seen = 0;
    pb->protect_count = 0;
    if (!pb->enabled)
    {
        return;
    }
    SEXP config = PROTECT(progress_make_config(progress, default_name));
    pb->bar = PROTECT(cli_progress_bar((double) total, config));
    pb->protect_count = 1;
    UNPROTECT(1);
}

static void progress_tick(progress_t *pb)
{
    pb->seen++;
    if (pb->seen % 128 == 0)
    {
        R_CheckUserInterrupt();
    }
    if (!pb->enabled)
    {
        return;
    }
    pb->current++;
    double current = (double) pb->current;
    if (pb->current > pb->total)
    {
        current = (double) pb->total;
    }
    if (CLI_SHOULD_TICK)
    {
        cli_progress_set(pb->bar, current);
    }
}

static void progress_done(progress_t *pb)
{
    if (!pb->enabled)
    {
        return;
    }
    cli_progress_update(
        pb->bar,
        (double) pb->total,
        -1.0,
        1
    );
    cli_progress_done(pb->bar);
    if (pb->protect_count > 0)
    {
        UNPROTECT(pb->protect_count);
        pb->protect_count = 0;
    }
    pb->bar = R_NilValue;
}

/* -------------------------------------------------------------------------- */
/* utilities                                                                  */
/* -------------------------------------------------------------------------- */

static void copy_names(SEXP out, SEXP x)
{
    SEXP nms = Rf_getAttrib(x, R_NamesSymbol);
    if (nms != R_NilValue && XLENGTH(nms) == XLENGTH(out))
    {
        Rf_setAttrib(out, R_NamesSymbol, nms);
    }
}

static SEXP tag_from_names(SEXP nms, R_xlen_t i)
{
    if (nms == R_NilValue || i >= XLENGTH(nms))
    {
        return R_NilValue;
    }
    SEXP chr = STRING_ELT(nms, i);
    if (chr == NA_STRING || strlen(CHAR(chr)) == 0)
    {
        return R_NilValue;
    }
    return Rf_install(CHAR(chr));
}

static void append_arg(SEXP *tail, SEXP value, SEXP tag)
{
    SEXP node = Rf_cons(value, R_NilValue);
    if (tag != R_NilValue)
    {
        SET_TAG(node, tag);
    }
    SETCDR(*tail, node);
    *tail = node;
}

static void append_dots(SEXP *tail, SEXP dots)
{
    SEXP nms = Rf_getAttrib(dots, R_NamesSymbol);
    for (R_xlen_t i = 0; i < XLENGTH(dots); i++)
    {
        SEXP tag = tag_from_names(nms, i);
        append_arg(tail, VECTOR_ELT(dots, i), tag);
    }
}

static SEXP make_call1(SEXP f, SEXP x, SEXP dots)
{
    SEXP call = PROTECT(Rf_lcons(f, R_NilValue));
    SEXP tail = call;
    append_arg(&tail, x, R_NilValue);
    append_dots(&tail, dots);
    return call;
}

static SEXP make_call2(SEXP f, SEXP x, SEXP y, SEXP dots)
{
    SEXP call = PROTECT(Rf_lcons(f, R_NilValue));
    SEXP tail = call;
    append_arg(&tail, x, R_NilValue);
    append_arg(&tail, y, R_NilValue);
    append_dots(&tail, dots);
    return call;
}

static SEXP make_call_values(SEXP f, SEXP xs, int use_names, SEXP dots)
{
    SEXP call = PROTECT(Rf_lcons(f, R_NilValue));
    SEXP tail = call;
    SEXP nms = use_names ? Rf_getAttrib(xs, R_NamesSymbol) : R_NilValue;
    for (R_xlen_t i = 0; i < XLENGTH(xs); i++)
    {
        SEXP tag = use_names ? tag_from_names(nms, i) : R_NilValue;
        append_arg(&tail, VECTOR_ELT(xs, i), tag);
    }
    append_dots(&tail, dots);
    return call;
}

static SEXP make_key(SEXP nms, R_xlen_t i)
{
    if (nms != R_NilValue && i < XLENGTH(nms))
    {
        SEXP chr = STRING_ELT(nms, i);
        if (chr != NA_STRING && strlen(CHAR(chr)) > 0)
        {
            return Rf_ScalarString(chr);
        }
    }
    char buf[64];
    snprintf(buf, sizeof(buf), "%lld", (long long) i + 1);
    return Rf_mkString(buf);
}

static SEXP path_append(SEXP path, SEXP key)
{
    R_xlen_t n = XLENGTH(path);
    SEXP out = PROTECT(Rf_allocVector(STRSXP, n + 1));
    for (R_xlen_t i = 0; i < n; i++)
    {
        SET_STRING_ELT(out, i, STRING_ELT(path, i));
    }
    SET_STRING_ELT(out, n, STRING_ELT(key, 0));
    return out;
}

/* -------------------------------------------------------------------------- */
/* list_map                                                                   */
/* -------------------------------------------------------------------------- */

static SEXP rec_map(SEXP x, SEXP f, SEXP dots, SEXP env, progress_t *pb)
{
    if (is_plain_list(x))
    {
        R_xlen_t n = XLENGTH(x);
        SEXP out = PROTECT(Rf_allocVector(VECSXP, n));
        copy_names(out, x);
        for (R_xlen_t i = 0; i < n; i++)
        {
            SEXP child = PROTECT(rec_map(VECTOR_ELT(x, i), f, dots, env, pb));
            SET_VECTOR_ELT(out, i, child);
            UNPROTECT(1);
        }
        UNPROTECT(1);
        return out;
    }
    progress_tick(pb);
    SEXP call = make_call1(f, x, dots);
    SEXP ans = PROTECT(Rf_eval(call, env));
    UNPROTECT(2);
    return ans;
}

SEXP lstrrr_c_list_map(
    SEXP x,
    SEXP f,
    SEXP dots,
    SEXP progress,
    SEXP env
)
{
    progress_t pb;
    progress_init(&pb, progress, nleaf_rec(x), "");
    SEXP out = PROTECT(rec_map(x, f, dots, env, &pb));
    progress_done(&pb);
    UNPROTECT(1);
    return out;
}

/* -------------------------------------------------------------------------- */
/* list_map2                                                                  */
/* -------------------------------------------------------------------------- */

static SEXP rec_map2(
    SEXP x,
    SEXP y,
    SEXP f,
    SEXP dots,
    SEXP env,
    progress_t *pb
)
{
    if (is_plain_list(x) && is_plain_list(y))
    {
        R_xlen_t nx = XLENGTH(x);
        R_xlen_t ny = XLENGTH(y);
        R_xlen_t n = nx > ny ? nx : ny;
        SEXP out = PROTECT(Rf_allocVector(VECSXP, n));
        SEXP nms_x = Rf_getAttrib(x, R_NamesSymbol);
        SEXP nms_y = Rf_getAttrib(y, R_NamesSymbol);
        if (nms_x != R_NilValue && XLENGTH(nms_x) == n)
        {
            Rf_setAttrib(out, R_NamesSymbol, nms_x);
        }
        else if (nms_y != R_NilValue && XLENGTH(nms_y) == n)
        {
            Rf_setAttrib(out, R_NamesSymbol, nms_y);
        }
        for (R_xlen_t i = 0; i < n; i++)
        {
            SEXP xi = i < nx ? VECTOR_ELT(x, i) : R_NilValue;
            SEXP yi = i < ny ? VECTOR_ELT(y, i) : R_NilValue;
            SEXP child = PROTECT(rec_map2(xi, yi, f, dots, env, pb));
            SET_VECTOR_ELT(out, i, child);
            UNPROTECT(1);
        }
        UNPROTECT(1);
        return out;
    }
    progress_tick(pb);
    SEXP call = make_call2(f, x, y, dots);
    SEXP ans = PROTECT(Rf_eval(call, env));
    UNPROTECT(2);
    return ans;
}

SEXP lstrrr_c_list_map2(
    SEXP x,
    SEXP y,
    SEXP f,
    SEXP dots,
    SEXP progress,
    SEXP env
)
{
    progress_t pb;
    progress_init(&pb, progress, nleaf_rec(x), "");
    SEXP out = PROTECT(rec_map2(x, y, f, dots, env, &pb));
    progress_done(&pb);
    UNPROTECT(1);
    return out;
}

/* -------------------------------------------------------------------------- */
/* list_pmap                                                                  */
/* -------------------------------------------------------------------------- */

static int all_plain_lists(SEXP xs)
{
    for (R_xlen_t i = 0; i < XLENGTH(xs); i++)
    {
        if (!is_plain_list(VECTOR_ELT(xs, i)))
        {
            return 0;
        }
    }
    return 1;
}

static SEXP rec_pmap(SEXP xs, SEXP f, SEXP dots, SEXP env, progress_t *pb)
{
    R_xlen_t k = XLENGTH(xs);
    if (k == 0)
    {
        Rf_error("`.l` must contain at least one element.");
    }
    if (all_plain_lists(xs))
    {
        R_xlen_t n = 0;
        R_xlen_t which_max = 0;
        for (R_xlen_t j = 0; j < k; j++)
        {
            R_xlen_t len = XLENGTH(VECTOR_ELT(xs, j));
            if (len > n)
            {
                n = len;
                which_max = j;
            }
        }
        SEXP out = PROTECT(Rf_allocVector(VECSXP, n));
        copy_names(out, VECTOR_ELT(xs, which_max));
        for (R_xlen_t i = 0; i < n; i++)
        {
            SEXP child_xs = PROTECT(Rf_allocVector(VECSXP, k));
            copy_names(child_xs, xs);
            for (R_xlen_t j = 0; j < k; j++)
            {
                SEXP z = VECTOR_ELT(xs, j);
                if (i < XLENGTH(z))
                {
                    SET_VECTOR_ELT(child_xs, j, VECTOR_ELT(z, i));
                }
                else
                {
                    SET_VECTOR_ELT(child_xs, j, R_NilValue);
                }
            }
            SEXP child = PROTECT(rec_pmap(child_xs, f, dots, env, pb));
            SET_VECTOR_ELT(out, i, child);
            UNPROTECT(2);
        }
        UNPROTECT(1);
        return out;
    }
    progress_tick(pb);
    SEXP call = make_call_values(f, xs, 1, dots);
    SEXP ans = PROTECT(Rf_eval(call, env));
    UNPROTECT(2);
    return ans;
}

SEXP lstrrr_c_list_pmap(
    SEXP xs,
    SEXP f,
    SEXP dots,
    SEXP progress,
    SEXP env
)
{
    if (TYPEOF(xs) != VECSXP)
    {
        Rf_error("`.l` must be a list.");
    }
    if (XLENGTH(xs) == 0)
    {
        Rf_error("`.l` must contain at least one element.");
    }
    progress_t pb;
    progress_init(&pb, progress, nleaf_rec(VECTOR_ELT(xs, 0)), "");
    SEXP out = PROTECT(rec_pmap(xs, f, dots, env, &pb));
    progress_done(&pb);
    UNPROTECT(1);
    return out;
}

/* -------------------------------------------------------------------------- */
/* list_imap                                                                  */
/* -------------------------------------------------------------------------- */

static SEXP rec_imap(
    SEXP x,
    SEXP f,
    SEXP dots,
    SEXP env,
    progress_t *pb,
    SEXP id,
    int use_path
)
{
    if (is_plain_list(x))
    {
        R_xlen_t n = XLENGTH(x);
        SEXP out = PROTECT(Rf_allocVector(VECSXP, n));
        copy_names(out, x);
        SEXP nms = Rf_getAttrib(x, R_NamesSymbol);
        for (R_xlen_t i = 0; i < n; i++)
        {
            SEXP key = PROTECT(make_key(nms, i));
            if (use_path)
            {
                SEXP next_id = path_append(id, key);
                SEXP child = PROTECT(
                                 rec_imap(VECTOR_ELT(x, i), f, dots, env, pb, next_id, use_path)
                             );
                SET_VECTOR_ELT(out, i, child);
                UNPROTECT(3);
            }
            else
            {
                SEXP child = PROTECT(
                                 rec_imap(VECTOR_ELT(x, i), f, dots, env, pb, key, use_path)
                             );
                SET_VECTOR_ELT(out, i, child);
                UNPROTECT(2);
            }
        }
        UNPROTECT(1);
        return out;
    }
    progress_tick(pb);
    SEXP call = make_call2(f, x, id, dots);
    SEXP ans = PROTECT(Rf_eval(call, env));
    UNPROTECT(2);
    return ans;
}

SEXP lstrrr_c_list_imap(
    SEXP x,
    SEXP f,
    SEXP dots,
    SEXP name_mode,
    SEXP progress,
    SEXP env
)
{
    int use_path = 0;
    if (TYPEOF(name_mode) == STRSXP &&
            XLENGTH(name_mode) == 1 &&
            strcmp(CHAR(STRING_ELT(name_mode, 0)), "path") == 0)
    {
        use_path = 1;
    }
    progress_t pb;
    progress_init(&pb, progress, nleaf_rec(x), "");
    SEXP id = PROTECT(Rf_allocVector(STRSXP, 0));
    SEXP out = PROTECT(
                   rec_imap(x, f, dots, env, &pb, id, use_path)
               );
    progress_done(&pb);
    UNPROTECT(2);
    return out;
}
