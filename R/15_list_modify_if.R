#' Modify leaves satisfying predicate
#'
#' @inheritParams list_map
#' @inherit list_find
#'
#' @return
#' A nested list with the same structure and names as `x`, where leaves
#' satisfying `.p` have been replaced by the result of `.f`.
#'
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 2,
#'     y = list(i = 3, j = 4)
#'   ),
#'   c = "text"
#' )
#'
#' # Double numeric leaves greater than 2
#' list_modify_if(
#'   x,
#'   .p = \(value) is.numeric(value) && value > 2,
#'   .f = \(value) value * 2
#' )
#'
#' # Modify only character leaves
#' list_modify_if(
#'   x,
#'   .p = is.character,
#'   .f = toupper
#' )
#'
#' # Additional arguments are passed to `.f`
#' list_modify_if(
#'   x,
#'   .p = is.numeric,
#'   .f = \(value, increment) value + increment,
#'   increment = 10
#' )
#'
#' # Data frames are treated as leaves
#' x2 <- list(a = data.frame(x = 1:3), b = list(c = 1))
#' list_modify_if(x2, is.data.frame, \(value) transform(value, y = x * 2))
#'
#' @family lstrrr-purrrlike
#' @export
list_modify_if <- function(.x, .p, .f, ...) {
  .p <- as_function(.p)
  .f <- as_function(.f)

  if (is.list(.x) && !is.data.frame(.x)) {
    out <- vector("list", length(.x))
    names(out) <- names(.x)

    for (i in seq_along(.x)) {
      out[[i]] <- list_modify_if(.x[[i]], .p, .f, ...)
    }

    out
  } else {
    if (isTRUE(.p(.x))) .f(.x, ...) else .x
  }
}
