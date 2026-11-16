#include "lstrrr.h"
#include <R_ext/Rdynload.h>
#include <stdlib.h> // for NULL

SEXP lstrrr_c_modify_list(SEXP x, SEXP val, SEXP keep_null);
SEXP lstrrr_c_list_get(SEXP x, SEXP path, SEXP def);
SEXP lstrrr_c_list_has(SEXP x, SEXP path);
SEXP lstrrr_c_list_depth(SEXP x);
SEXP lstrrr_c_list_path(SEXP x);
SEXP lstrrr_c_list_flatten(SEXP x, SEXP sep);
SEXP lstrrr_c_list_set(SEXP x, SEXP path, SEXP value);
SEXP lstrrr_c_list_delete(SEXP x, SEXP path);
SEXP lstrrr_c_list_rename(SEXP x, SEXP path, SEXP name);
SEXP lstrrr_c_list_nleaf(SEXP x);
SEXP lstrrr_c_list_find_val(SEXP x, SEXP value);
SEXP lstrrr_c_list_map(SEXP x, SEXP f, SEXP dots, SEXP progress, SEXP env);
SEXP lstrrr_c_list_map2(SEXP x, SEXP y, SEXP f, SEXP dots, SEXP progress,
                        SEXP env);
SEXP lstrrr_c_list_pmap(SEXP xs, SEXP f, SEXP dots, SEXP progress, SEXP env);
SEXP lstrrr_c_list_imap(SEXP x, SEXP f, SEXP dots, SEXP name_mode,
                        SEXP progress, SEXP env);

static const R_CallMethodDef CallEntries[] = {
    {"lstrrr_c_modify_list", (DL_FUNC)&lstrrr_c_modify_list, 3},
    {"lstrrr_c_list_get", (DL_FUNC)&lstrrr_c_list_get, 3},
    {"lstrrr_c_list_has", (DL_FUNC)&lstrrr_c_list_has, 2},
    {"lstrrr_c_list_depth", (DL_FUNC)&lstrrr_c_list_depth, 1},
    {"lstrrr_c_list_path", (DL_FUNC)&lstrrr_c_list_path, 1},
    {"lstrrr_c_list_flatten", (DL_FUNC)&lstrrr_c_list_flatten, 2},
    {"lstrrr_c_list_set", (DL_FUNC)&lstrrr_c_list_set, 3},
    {"lstrrr_c_list_delete", (DL_FUNC)&lstrrr_c_list_delete, 2},
    {"lstrrr_c_list_rename", (DL_FUNC)&lstrrr_c_list_rename, 3},
    {"lstrrr_c_list_nleaf", (DL_FUNC)&lstrrr_c_list_nleaf, 1},
    {"lstrrr_c_list_find_val", (DL_FUNC)&lstrrr_c_list_find_val, 2},
    {"lstrrr_c_list_map", (DL_FUNC)&lstrrr_c_list_map, 5},
    {"lstrrr_c_list_map2", (DL_FUNC)&lstrrr_c_list_map2, 6},
    {"lstrrr_c_list_pmap", (DL_FUNC)&lstrrr_c_list_pmap, 5},
    {"lstrrr_c_list_imap", (DL_FUNC)&lstrrr_c_list_imap, 6},
    {NULL, NULL, 0}};

void R_init_lstrrr(DllInfo *dll) {
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
