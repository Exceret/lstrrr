#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <R_ext/Print.h>
#include <R_ext/Utils.h>

#include <string.h>
#include <limits.h>
#include <stdio.h>

static int is_data_frame(SEXP x)
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

static int nleaf_is_plain_list(SEXP x)
{
    return TYPEOF(x) == VECSXP && !is_data_frame(x);
}

static R_xlen_t nleaf_rec(SEXP x)
{
    if (!nleaf_is_plain_list(x))
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
/* spinner progress                                                           */
/* -------------------------------------------------------------------------- */

typedef struct
{
    int enabled;
    const char *name;
    R_xlen_t total;
    R_xlen_t current;
    R_xlen_t seen;
    int frame;
} spinner_t;

static const char *spinner_frames[] =
{
    "\xE2\xA0\x8B", "\xE2\xA0\x99", "\xE2\xA0\xB9", "\xE2\xA0\xB8",
    "\xE2\xA0\xBC", "\xE2\xA0\xB4", "\xE2\xA0\xA6", "\xE2\xA0\xA7",
    "\xE2\xA0\x87", "\xE2\xA0\x8F"
};

static int progress_enabled(SEXP progress)
{
    if (TYPEOF(progress) == LGLSXP &&
            XLENGTH(progress) >= 1 &&
            LOGICAL(progress)[0] == TRUE)
    {
        return 1;
    }
    if (TYPEOF(progress) == STRSXP)
    {
        return 1;
    }
    return 0;
}

static const char *progress_name(SEXP progress, const char *default_name)
{
    if (TYPEOF(progress) == STRSXP &&
            XLENGTH(progress) == 1 &&
            STRING_ELT(progress, 0) != NA_STRING &&
            strlen(CHAR(STRING_ELT(progress, 0))) > 0)
    {
        return CHAR(STRING_ELT(progress, 0));
    }
    return default_name;
}

static void spinner_render(spinner_t *pb, int done)
{
    if (!pb->enabled)
    {
        return;
    }
    double pct = 100.0;
    if (pb->total > 0)
    {
        pct = 100.0 * ((double) pb->current / (double) pb->total);
        if (pct > 100.0)
        {
            pct = 100.0;
        }
    }
    const char *mark;
    if (done)
    {
        mark = "\033[32m\xE2\x9C\x94\033[0m";
    }
    else
    {
        mark = spinner_frames[pb->frame % 10];
    }
    Rprintf(
        "\r%s %s %.0f/%.0f (%3.0f%%)   ",
        mark,
        pb->name,
        (double) pb->current,
        (double) pb->total,
        pct
    );
    if (done)
    {
        Rprintf("\n");
    }
    R_FlushConsole();
}

static void spinner_init(
    spinner_t *pb,
    SEXP progress,
    R_xlen_t total,
    const char *default_name
)
{
    pb->enabled = progress_enabled(progress) && total > 0;
    pb->name = progress_name(progress, default_name);
    pb->total = total;
    pb->current = 0;
    pb->seen = 0;
    pb->frame = 0;
    spinner_render(pb, 0);
}

static void spinner_tick(spinner_t *pb)
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
    pb->frame++;
    spinner_render(pb, 0);
}

static void spinner_done(spinner_t *pb)
{
    if (!pb->enabled)
    {
        return;
    }
    pb->current = pb->total;
    spinner_render(pb, 1);
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

static SEXP rec_map(SEXP x, SEXP f, SEXP dots, SEXP env, spinner_t *pb)
{
    if (nleaf_is_plain_list(x))
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
    spinner_tick(pb);
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
    spinner_t pb;
    spinner_init(&pb, progress, nleaf_rec(x), "Task");
    SEXP out = PROTECT(rec_map(x, f, dots, env, &pb));
    spinner_done(&pb);
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
    spinner_t *pb
)
{
    if (nleaf_is_plain_list(x) && nleaf_is_plain_list(y))
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
    spinner_tick(pb);
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
    spinner_t pb;
    spinner_init(&pb, progress, nleaf_rec(x), "map2");
    SEXP out = PROTECT(rec_map2(x, y, f, dots, env, &pb));
    spinner_done(&pb);
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
        if (!nleaf_is_plain_list(VECTOR_ELT(xs, i)))
        {
            return 0;
        }
    }
    return 1;
}

static SEXP rec_pmap(SEXP xs, SEXP f, SEXP dots, SEXP env, spinner_t *pb)
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
    spinner_tick(pb);
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
    spinner_t pb;
    spinner_init(&pb, progress, nleaf_rec(VECTOR_ELT(xs, 0)), "pmap");
    SEXP out = PROTECT(rec_pmap(xs, f, dots, env, &pb));
    spinner_done(&pb);
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
    spinner_t *pb,
    SEXP id,
    int use_path
)
{
    if (nleaf_is_plain_list(x))
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
    spinner_tick(pb);
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
    spinner_t pb;
    spinner_init(&pb, progress, nleaf_rec(x), use_path ? "imap-path" : "imap");
    SEXP id = PROTECT(Rf_allocVector(STRSXP, 0));
    SEXP out = PROTECT(
                   rec_imap(x, f, dots, env, &pb, id, use_path)
               );
    spinner_done(&pb);
    UNPROTECT(2);
    return out;
}
