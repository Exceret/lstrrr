#' Filter leaves of a nested list
#'
#' Keeps the original nested-list structure. Leaves for which `.p`
#' returns `FALSE` are replaced by `NULL`.
#'
#' @inheritParams list_map
#' @inheritParams list_find
#' @return
#' A nested list with the same structure and names as `.x`.
#'
#' @export
#' @family lstrrr-purrrlike
list_filter <- function(.x, .p, .progress = FALSE) {
  .p <- as_function(.p)

  keep <- function(value) {
    if (isTRUE(.p(value))) {
      value
    } else {
      NULL
    }
  }

  list_map(
    .x = .x,
    .f = keep,
    .progress = .progress
  )
}
