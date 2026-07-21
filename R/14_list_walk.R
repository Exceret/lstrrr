#' Walk over leaves of a nested list
#'
#' Applies `.f` to each leaf of `x` for side effects.
#'
#' @inherit list_map
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 2,
#'     y = list(i = 3, j = 4)
#'   )
#' )
#'
#' # Print each leaf
#' list_walk(x, print)
#'
#' # Use additional arguments
#' list_walk(x, \(value, prefix) message(prefix, value, "\n"), prefix = "value:")
#'
#'
#' @return Invisibly returns `x`.
#' @family lstrrr-purrrlike
#' @export
list_walk <- function(x, .f, ...) {
  .f <- as_function(.f)

  walk_rec <- function(obj) {
    if (is.list(obj) && !is.data.frame(obj)) {
      for (i in seq_along(obj)) {
        walk_rec(obj[[i]])
      }
    } else {
      .f(obj, ...)
    }
  }

  walk_rec(x)

  invisible(x)
}

#' Walk over leaves of two nested lists
#'
#' Applies `.f` to corresponding leaves of `x` and `y` for side effects.
#'
#' @inherit list_map2
#'
#' @return Invisibly returns `x`.
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 2,
#'     y = list(i = 3, j = 4)
#'   )
#' )
#'
#' # Print each leaf
#' list_walk2(x, x, ~ message(.x +.y))
#'
#'
#' @family lstrrr-purrrlike
#' @export
list_walk2 <- function(x, y, .f, ...) {
  .f <- as_function(.f)

  walk2_rec <- function(a, b) {
    a_is_list <- is.list(a) && !is.data.frame(a)
    b_is_list <- is.list(b) && !is.data.frame(b)

    if (a_is_list && b_is_list) {
      n <- max(length(a), length(b))

      for (i in seq_len(n)) {
        ai <- if (i <= length(a)) a[[i]] else NULL
        bi <- if (i <= length(b)) b[[i]] else NULL

        walk2_rec(ai, bi)
      }
    } else {
      .f(a, b, ...)
    }
  }

  walk2_rec(x, y)

  invisible(x)
}

#' Walk over leaves of multiple nested lists
#'
#' Applies `.f` to corresponding leaves of multiple nested lists
#' for side effects.
#'
#' @inherit list_pmap
#'
#' @return Invisibly returns `.l`.
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 2,
#'     y = list(i = 3, j = 4)
#'   )
#' )
#'
#' # Print each leaf
#' list_pwalk(.l = list(x, x, x, x), .f = function(x, y, z, w = 1) message((x + y) * z + w))
#' # 3
#' # 10
#' # 21
#' # 36
#'
#' @family lstrrr-purrrlike
#' @export
list_pwalk <- function(.l, .f, ...) {
  .f <- as_function(.f)

  if (!is.list(.l)) {
    cli::cli_abort(
      message = c("x" = "`.l` must be a {.cls list}."),
      call = caller_call(),
      .frame = caller_env()
    )
  }

  pwalk_rec <- function(xs) {
    are_lists <- vapply(
      xs,
      function(z) is.list(z) && !is.data.frame(z),
      logical(1)
    )

    if (all(are_lists)) {
      lens <- lengths(xs)
      n <- max(lens)

      for (i in seq_len(n)) {
        pwalk_rec(lapply(xs, function(z) {
          if (i <= length(z)) z[[i]] else NULL
        }))
      }
    } else {
      do.call(.f, c(xs, list(...)))
    }
  }

  pwalk_rec(.l)

  invisible(.l)
}
