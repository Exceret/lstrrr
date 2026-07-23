#' Find leaves satisfying predicate
#'
#' @inheritParams list_map
#' @param .p A predicate function, formula, or function-like object coercible by
#'   [rlang::as_function()].
#'
#' @return
#' A flat list containing the leaf values of `x` for which `.p` returns `TRUE`.
#'
#' The names of the returned list correspond to the flattened paths of the
#' matching leaves.
#'
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 2,
#'     y = list(i = 3, j = 4)
#'   ),
#'   unnamed = list(5, z = 6)
#' )
#' list_find(x, ~ .x > 2 & .x < 5)
#' # $b.y.i
#' # [1] 3
#' #
#' # $b.y.j
#' # [1] 4
#'
#' # Use a regular function
#' list_find(x, function(value) value %% 2 == 0)
#'
#' # Non-TRUE predicate results are not kept
#' list_find(x, ~ NA)
#'
#' @seealso [list_flatten()]
#'
#'
#'
#' @export
list_find <- function(.x, .p) {
  .p <- as_function(.p)
  flat <- list_flatten(.x)

  keep <- vapply(flat, function(z) isTRUE(.p(z)), logical(1L))
  flat[keep]
}

#' Flatten a nested list
#'
#' @inheritParams list_map
#' @param .sep Separator used to join path names.
#'
#' @family lstrrr-purrrlike
#' @export
list_flatten <- function(.x, .sep = ".") {
  .Call("lstrrr_c_list_flatten", .x, .sep, PACKAGE = "lstrrr")
}
