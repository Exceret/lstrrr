#include "lstrrr.h"
#include <string.h>

static int is_valid_name(SEXP name) {
  if (name == NA_STRING) {
    return 0;
  }
  const char *s = CHAR(name);
  return s[0] != '\0';
}

static R_xlen_t find_name(SEXP names, SEXP key) {
  if (names == R_NilValue || TYPEOF(names) != STRSXP || key == NA_STRING) {
    return -1;
  }
  const char *k = CHAR(key);
  for (R_xlen_t i = 0; i < XLENGTH(names); i++) {
    SEXP nm = STRING_ELT(names, i);
    if (nm == NA_STRING) {
      continue;
    }
    if (strcmp(CHAR(nm), k) == 0) {
      return i;
    }
  }
  return -1;
}

static SEXP append_value(SEXP x, SEXP key, SEXP value, int has_key) {
  R_xlen_t n = XLENGTH(x);
  SEXP out = PROTECT(Rf_allocVector(VECSXP, n + 1));
  SEXP old_names = Rf_getAttrib(x, R_NamesSymbol);
  int make_names = has_key || old_names != R_NilValue;
  SEXP out_names = R_NilValue;
  if (make_names) {
    out_names = PROTECT(Rf_allocVector(STRSXP, n + 1));
  }
  SEXP blank = Rf_mkChar("");
  for (R_xlen_t i = 0; i < n; i++) {
    SET_VECTOR_ELT(out, i, VECTOR_ELT(x, i));
    if (make_names) {
      if (old_names != R_NilValue && i < XLENGTH(old_names)) {
        SET_STRING_ELT(out_names, i, STRING_ELT(old_names, i));
      } else {
        SET_STRING_ELT(out_names, i, blank);
      }
    }
  }
  SET_VECTOR_ELT(out, n, value);
  if (make_names) {
    SET_STRING_ELT(out_names, n, has_key ? key : blank);
    Rf_setAttrib(out, R_NamesSymbol, out_names);
    UNPROTECT(1);
  }
  SEXP cls = Rf_getAttrib(x, R_ClassSymbol);
  if (cls != R_NilValue) {
    Rf_setAttrib(out, R_ClassSymbol, cls);
  }
  UNPROTECT(1);
  return out;
}

// static SEXP append_named(SEXP x, SEXP key, SEXP value)
// {
//     R_xlen_t n = XLENGTH(x);
//     SEXP out = PROTECT(Rf_allocVector(VECSXP, n + 1));
//     SEXP out_names = PROTECT(Rf_allocVector(STRSXP, n + 1));
//     SEXP old_names = Rf_getAttrib(x, R_NamesSymbol);
//     for (R_xlen_t i = 0; i < n; i++)
//     {
//         SET_VECTOR_ELT(out, i, VECTOR_ELT(x, i));
//         if (old_names != R_NilValue && i < XLENGTH(old_names))
//         {
//             SET_STRING_ELT(out_names, i, STRING_ELT(old_names, i));
//         }
//         else
//         {
//             SET_STRING_ELT(out_names, i, Rf_mkChar(""));
//         }
//     }
//     SET_VECTOR_ELT(out, n, value);
//     SET_STRING_ELT(out_names, n, key);
//     Rf_setAttrib(out, R_NamesSymbol, out_names);
//     UNPROTECT(2);
//     return out;
// }

static int get_valid_name_at(SEXP names, R_xlen_t i, SEXP *key) {
  if (names == R_NilValue || TYPEOF(names) != STRSXP || i >= XLENGTH(names)) {
    return 0;
  }
  SEXP nm = STRING_ELT(names, i);
  if (!is_valid_name(nm)) {
    return 0;
  }
  *key = nm;
  return 1;
}

static SEXP remove_at(SEXP x, R_xlen_t idx) {
  R_xlen_t n = XLENGTH(x);
  if (idx < 0 || idx >= n) {
    return x;
  }
  SEXP out = PROTECT(Rf_allocVector(VECSXP, n - 1));
  SEXP old_names = Rf_getAttrib(x, R_NamesSymbol);
  int has_names = old_names != R_NilValue;
  SEXP out_names = R_NilValue;
  if (has_names) {
    out_names = PROTECT(Rf_allocVector(STRSXP, n - 1));
  }
  SEXP blank = Rf_mkChar("");
  R_xlen_t j = 0;
  for (R_xlen_t i = 0; i < n; i++) {
    if (i == idx) {
      continue;
    }
    SET_VECTOR_ELT(out, j, VECTOR_ELT(x, i));
    if (has_names) {
      if (i < XLENGTH(old_names)) {
        SET_STRING_ELT(out_names, j, STRING_ELT(old_names, i));
      } else {
        SET_STRING_ELT(out_names, j, blank);
      }
    }
    j++;
  }
  if (has_names) {
    Rf_setAttrib(out, R_NamesSymbol, out_names);
    UNPROTECT(1);
  }
  SEXP cls = Rf_getAttrib(x, R_ClassSymbol);
  if (cls != R_NilValue) {
    Rf_setAttrib(out, R_ClassSymbol, cls);
  }
  UNPROTECT(1);
  return out;
}

static SEXP modify_list_rec(SEXP x, SEXP val, int keep_null) {
  if (!is_plain_list(x)) {
    Rf_error("`x` must be a list.");
  }
  if (!is_plain_list(val)) {
    Rf_error("`val` must be a list.");
  }
  SEXP val_names = Rf_getAttrib(val, R_NamesSymbol);
  SEXP out;
  PROTECT_INDEX out_pi;
  PROTECT_WITH_INDEX(out = shallow_copy_list(x), &out_pi);
  for (R_xlen_t i = 0; i < XLENGTH(val); i++) {
    SEXP key = R_NilValue;
    int has_key = get_valid_name_at(val_names, i, &key);
    SEXP v = VECTOR_ELT(val, i);
    /*
     * 未命名元素：
     * 不查找同名项，不覆盖，直接追加。
     */
    if (!has_key) {
      if (v == R_NilValue && !keep_null) {
        continue;
      }
      REPROTECT(out = append_value(out, key, v, 0), out_pi);
      continue;
    }
    SEXP out_names = Rf_getAttrib(out, R_NamesSymbol);
    R_xlen_t pos = find_name(out_names, key);
    if (v == R_NilValue && !keep_null) {
      if (pos >= 0) {
        REPROTECT(out = remove_at(out, pos), out_pi);
      }
      continue;
    }
    if (pos >= 0 && is_plain_list(VECTOR_ELT(out, pos)) && is_plain_list(v)) {
      SEXP merged =
          PROTECT(modify_list_rec(VECTOR_ELT(out, pos), v, keep_null));
      SET_VECTOR_ELT(out, pos, merged);
      UNPROTECT(1);
    } else {
      if (pos >= 0) {
        SET_VECTOR_ELT(out, pos, v);
      } else {
        REPROTECT(out = append_value(out, key, v, 1), out_pi);
      }
    }
  }
  UNPROTECT(1);
  return out;
}
SEXP lstrrr_c_modify_list(SEXP x, SEXP val, SEXP keep_null) {
  if (TYPEOF(keep_null) != LGLSXP || XLENGTH(keep_null) != 1) {
    Rf_error("`keep.null` must be TRUE or FALSE.");
  }
  int keep = LOGICAL(keep_null)[0];
  if (keep == NA_LOGICAL) {
    Rf_error("`keep.null` must not be NA.");
  }
  return modify_list_rec(x, val, keep);
}
