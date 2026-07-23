#' Modify a List with Another List
#'
#' A faster version of [utils::modifyList()].
#'
#' @param x A nested list to traverse.
#'
#'   Lists are traversed recursively. Non-list objects are treated as leaves.
#'   Data frames are not traversed and are treated as leaf values.
#' @param val A named list whose components modify `x`.
#' @param keep.null Logical. If `TRUE`, `NULL` values in `val` are kept.
#'   If `FALSE`, `NULL` values remove corresponding components from `x`.
#'
#' @return A modified list.
#'
#' @examples
#' \donttest{
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   )
#' )
#'
#' val <- list(
#'   b = list(
#'     y = list(j = 99, k = 100)
#'   ),
#'   c = 3
#' )
#'
#' modify_list(x, val)
#' }
#'
#' @export
modify_list <- function(x, val, keep.null = FALSE) {
  .Call(lstrrr_c_modify_list, x, val, keep.null)
}
