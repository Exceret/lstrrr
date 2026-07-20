#' Walk over leaves of a nested list
#'
#' Applies `.f` to each leaf of `x` for side effects.
#'
#' @param x A nested list.
#' @param .f A function applied to each leaf.
#' @param ... Additional arguments passed to `.f`.
#'
#' @return Invisibly returns `x`.
#'
#' @export
list_walk <- function(x, .f, ...) {
  .f <- match.fun(.f)

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
#' @param x A nested list.
#' @param y A nested list.
#' @param .f A function taking two leaf values.
#' @param ... Additional arguments passed to `.f`.
#'
#' @return Invisibly returns `x`.
#'
#' @export
list_walk2 <- function(x, y, .f, ...) {
  .f <- match.fun(.f)

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
#' @param .l A list of nested lists.
#' @param .f A function.
#' @param ... Additional arguments passed to `.f`.
#'
#' @return Invisibly returns `.l`.
#'
#' @export
list_pwalk <- function(.l, .f, ...) {
  .f <- match.fun(.f)

  if (!is.list(.l)) {
    stop("`.l` must be a list.", call. = FALSE)
  }

  pwalk_rec <- function(xs) {
    are_lists <- vapply(
      xs,
      function(z) is.list(z) && !is.data.frame(z),
      logical(1)
    )

    if (all(are_lists)) {
      lens <- vapply(lengths(xs))
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
