#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

SEXP lstrrr_c_modify_list(SEXP x, SEXP val, SEXP keep_null);
SEXP lstrrr_c_list_get(SEXP x, SEXP path, SEXP def);
SEXP lstrrr_c_list_has(SEXP x, SEXP path);
SEXP lstrrr_c_list_depth(SEXP x);
SEXP lstrrr_c_list_path(SEXP x);
SEXP lstrrr_c_list_flatten(SEXP x, SEXP sep);
SEXP lstrrr_c_list_set(SEXP x, SEXP path, SEXP value);
SEXP lstrrr_c_list_delete(SEXP x, SEXP path);

static const R_CallMethodDef CallEntries[] =
{
    {"lstrrr_c_modify_list", (DL_FUNC) &lstrrr_c_modify_list, 3},
    {"lstrrr_c_list_get", (DL_FUNC) &lstrrr_c_list_get,     3},
    {"lstrrr_c_list_has", (DL_FUNC) &lstrrr_c_list_has,     2},
    {"lstrrr_c_list_depth", (DL_FUNC) &lstrrr_c_list_depth,   1},
    {"lstrrr_c_list_path", (DL_FUNC) &lstrrr_c_list_path,    1},
    {"lstrrr_c_list_flatten", (DL_FUNC) &lstrrr_c_list_flatten, 2},
    {"lstrrr_c_list_set", (DL_FUNC) &lstrrr_c_list_set,     3},
    {"lstrrr_c_list_delete", (DL_FUNC) &lstrrr_c_list_delete,  2},
    {NULL, NULL, 0}
};

void R_init_lstrrr(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
