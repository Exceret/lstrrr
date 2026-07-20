#' Modify leaves satisfying predicate
#'
#' @param x A nested list.
#' @param .p Predicate function.
#' @param .f Function applied to matched leaves.
#' @param ... Additional arguments passed to `.f`.
#' @export
list_modify_if <- function(x, .p, .f, ...) {
  .p <- match.fun(.p)
  .f <- match.fun(.f)

  if (is.list(x) && !is.data.frame(x)) {
    out <- vector("list", length(x))
    names(out) <- names(x)

    for (i in seq_along(x)) {
      out[[i]] <- list_modify_if(x[[i]], .p, .f, ...)
    }

    out
  } else {
    if (isTRUE(.p(x))) .f(x, ...) else x
  }
}
