#' Walk over leaves of a nested list
#'
#' Applies `.f` to each leaf of `x` for side effects.
#'
#' @inheritParams list_map
#'
#' @return Invisibly returns `.x`.
#' @family lstrrr-purrrlike
#' @export
list_walk <- function(.x, .f, ..., .progress = FALSE) {
  list_map(.x = .x, .f = .f, ..., .progress = .progress)
  invisible(.x)
}

#' Walk over leaves of two nested lists
#'
#' Applies `.f` to corresponding leaves of `.x` and `.y` for side effects.
#'
#' @inheritParams list_map2
#'
#' @return Invisibly returns `.x`.
#' @family lstrrr-purrrlike
#' @export
list_walk2 <- function(.x, .y, .f, ..., .progress = FALSE) {
  list_map2(.x = .x, .y = .y, .f = .f, ..., .progress = .progress)
  invisible(.x)
}

#' Walk over leaves of multiple nested lists
#'
#' Applies `.f` to corresponding leaves of multiple nested lists
#' for side effects.
#'
#' @inheritParams list_pmap
#'
#' @return Invisibly returns `.l`.
#' @family lstrrr-purrrlike
#' @export
list_pwalk <- function(.l, .f, ..., .progress = FALSE) {
  list_pmap(.l = .l, .f = .f, ..., .progress = .progress)
  invisible(.l)
}

#' Walk over leaves of two nested lists
#'
#' Applies `.f` to corresponding leaves of `.x` and `.y` for side effects.
#'
#' @inheritParams list_imap
#'
#' @return Invisibly returns `.x`.
#' @family lstrrr-purrrlike
#' @export
list_iwalk <- function(.x, .f, ..., .progress = FALSE) {
  list_imap(.x = .x, .f = .f, ..., .progress = .progress)
  invisible(.x)
}
