#' Find leaves satisfying predicate
#'
#' @param x A nested list.
#' @param .p Predicate function.
#' @export
list_find <- function(x, .p) {
  .p <- match.fun(.p)
  flat <- list_flatten(x)

  keep <- vapply(flat, function(z) isTRUE(.p(z)), logical(1))
  flat[keep]
}

#' Flatten a nested list
#'
#' @param x A nested list.
#' @param sep Separator used to join path names.
#' @export
list_flatten <- function(x, sep = ".") {
  .Call("lstrrr_c_list_flatten", x, sep, PACKAGE = "lstrrr")
}
