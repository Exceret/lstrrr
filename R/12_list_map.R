#' Map over leaves of a nested list
#'
#' @param x A nested list.
#' @param .f A function.
#' @param ... Additional arguments passed to `.f`.
#' @export
list_map <- function(x, .f, ...) {
  .f <- match.fun(.f)

  if (is.list(x) && !is.data.frame(x)) {
    out <- vector("list", length(x))
    names(out) <- names(x)

    for (i in seq_along(x)) {
      out[[i]] <- list_map(x[[i]], .f, ...)
    }

    out
  } else {
    .f(x, ...)
  }
}

#' Map over leaves of two nested lists
#'
#' @param x A nested list.
#' @param y A nested list.
#' @param .f A function.
#' @param ... Additional arguments passed to `.f`.
#' @export
list_map2 <- function(x, y, .f, ...) {
  .f <- match.fun(.f)

  if (is.list(x) && !is.data.frame(x) && is.list(y) && !is.data.frame(y)) {
    n <- max(length(x), length(y))

    out <- vector("list", n)

    nx <- names(x)
    ny <- names(y)

    if (!is.null(nx)) {
      names(out) <- nx
    } else if (!is.null(ny)) {
      names(out) <- ny
    }

    for (i in seq_len(n)) {
      xi <- if (i <= length(x)) x[[i]] else NULL
      yi <- if (i <= length(y)) y[[i]] else NULL
      out[[i]] <- list_map2(xi, yi, .f, ...)
    }

    out
  } else {
    .f(x, y, ...)
  }
}

#' Map over leaves of multiple nested lists
#'
#' @param .l A list of nested lists.
#' @param .f A function.
#' @param ... Additional arguments passed to `.f`.
#' @export
list_pmap <- function(.l, .f, ...) {
  .f <- match.fun(.f)

  if (!is.list(.l)) {
    stop("`.l` must be a list.", call. = FALSE)
  }

  rec <- function(xs) {
    are_lists <- vapply(
      xs,
      function(z) is.list(z) && !is.data.frame(z),
      logical(1)
    )

    if (all(are_lists)) {
      each_length <- lengths(xs)
      n <- max(each_length)

      out <- vector("list", n)

      nms <- names(xs[[which.max(each_length)]])

      if (!is.null(nms)) {
        names(out) <- nms
      }

      for (i in seq_len(n)) {
        out[[i]] <- rec(lapply(xs, function(z) {
          if (i <= length(z)) z[[i]] else NULL
        }))
      }

      out
    } else {
      do.call(.f, c(xs, list(...)))
    }
  }

  rec(.l)
}

#' Map over leaves with path
#'
#' @param x A nested list.
#' @param .f A function taking value and path.
#' @param ... Additional arguments passed to `.f`.
#' @param .path A character specifying the root of the list in `x`
#' @export
list_imap <- function(x, .f, ..., .path = character()) {
  .f <- match.fun(.f)

  if (is.list(x) && !is.data.frame(x)) {
    out <- vector("list", length(x))
    names(out) <- names(x)

    nms <- names(x)

    for (i in seq_along(x)) {
      key <- if (!is.null(nms) && nzchar(nms[[i]])) {
        nms[[i]]
      } else {
        as.character(i)
      }

      out[[i]] <- list_imap(
        x[[i]],
        .f,
        ...,
        .path = c(.path, key)
      )
    }

    out
  } else {
    .f(x, .path, ...)
  }
}
