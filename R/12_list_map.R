#' Map over leaves of a nested list
#'
#' @param .x A nested list to traverse.
#'
#'   Lists are traversed recursively. Non-list objects are treated as leaves.
#'   Data frames are not traversed and are treated as leaf values.
#'
#' @param .f A function, formula, or function-like object coercible by
#'   [rlang::as_function()].
#'   Additional arguments supplied through `...` are passed on to `.f`.
#'
#' @param ... Additional arguments passed to `.f`.
#'
#' @param .progress Whether to show a progress bar.
#'
#'   Use TRUE to turn on a basic progress bar, use a string to give it a name
#'
#' @return
#' A list with the same nested structure as `.x`, where each leaf has been
#' replaced by the result of calling `.f` on that leaf.
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
#' x2 <- list_map(x, function(x) x - 2)
#' # $a
#' # [1] -1
#' #
#' # $b
#' # $b$x
#' # [1] -1
#' #
#' # $b$y
#' # $b$y$i
#' # [1] -1
#' #
#' # $b$y$j
#' # [1] 0
#' }
#'
#' @family lstrrr-purrrlike
#' @export
list_map <- function(.x, .f, ..., .progress = FALSE) {
  .f <- as_function(.f)

  total <- if (.list_progress_enabled(.progress)) {
    list_nleaf(.x)
  } else {
    0L
  }

  pb <- .list_progress_start(
    .progress = .progress,
    total = total
  )

  on.exit(.list_progress_done(pb), add = TRUE)

  .list_map_impl(
    .x = .x,
    .f = .f,
    ...,
    .pb = pb
  )
}

.list_map_impl <- function(.x, .f, ..., .pb = NULL) {
  if (is.list(.x) && !is.data.frame(.x)) {
    out <- vector("list", length(.x))
    names(out) <- names(.x)

    for (i in seq_along(.x)) {
      out[[i]] <- .list_map_impl(
        .x = .x[[i]],
        .f = .f,
        ...,
        .pb = .pb
      )
    }

    return(out)
  }

  .list_progress_tick(.pb)

  .f(.x, ...)
}

#' Map over leaves of two nested lists
#'
#' @inherit list_map
#' @param .y A nested list. Must have the same structure as `.x`.
#'
#' @family lstrrr-purrrlike
#' @examples
#' \donttest{
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   )
#' )
#' x2 <- list_map2(x, x, ~ {.x + .y})
#' # $a
#' # [1] 2
#' #
#' # $b
#' # $b$x
#' # [1] 2
#' #
#' # $b$y
#' # $b$y$i
#' # [1] 2
#' #
#' # $b$y$j
#' # [1] 4
#' }
#'
#' @export
list_map2 <- function(.x, .y, .f, ..., .progress = FALSE) {
  .f <- as_function(.f)

  total <- if (.list_progress_enabled(.progress)) {
    list_nleaf(.x)
  } else {
    0L
  }

  pb <- .list_progress_start(
    .progress = .progress,
    total = total
  )

  on.exit(.list_progress_done(pb), add = TRUE)

  .list_map2_impl(.x, .y, .f, ..., .pb = pb)
}

.list_map2_impl <- function(.x, .y, .f, ..., .pb = NULL) {
  if (is.list(.x) && !is.data.frame(.x) && is.list(.y) && !is.data.frame(.y)) {
    n <- max(length(.x), length(.y))

    out <- vector("list", n)

    nx <- names(.x)
    ny <- names(.y)

    if (!is.null(nx)) {
      names(out) <- nx
    } else if (!is.null(ny)) {
      names(out) <- ny
    }

    for (i in seq_len(n)) {
      xi <- if (i <= length(.x)) .x[[i]] else NULL
      yi <- if (i <= length(.y)) .y[[i]] else NULL
      out[[i]] <- .list_map2_impl(xi, yi, .f, ..., .pb = .pb)
    }

    out
  } else {
    .list_progress_tick(.pb)
    .f(.x, .y, ...)
  }
}

#' Map over leaves of multiple nested lists
#'
#' @inherit list_map
#' @param .l A list of nested lists.
#' @examples
#' \donttest{
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   )
#' )
#' list_pmap(list(x,x,x), function(x,y,z) (x + y) *z)
#' # $a
#' # [1] 2
#' #
#' # $b
#' # $b$x
#' # [1] 2
#' #
#' # $b$y
#' # $b$y$i
#' # [1] 2
#' #
#' # $b$y$j
#' # [1] 8
#'
#' }
#' @family lstrrr-purrrlike
#' @export
list_pmap <- function(.l, .f, ..., .progress = FALSE) {
  .f <- as_function(.f)

  if (!is.list(.l)) {
    cli::cli_abort(c("x" = "`.l` must be a {.cls list}."))
  }

  total <- if (.list_progress_enabled(.progress)) {
    list_nleaf(.l[[1L]])
  } else {
    0L
  }

  pb <- .list_progress_start(
    .progress = .progress,
    total = total
  )

  on.exit(.list_progress_done(pb), add = TRUE)

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
      .list_progress_tick(pb)
      do.call(.f, c(xs, list(...)))
    }
  }

  rec(.l)
}

#' Map over leaves with path (names)
#'
#' @inherit list_map
#' @param .name A character scalar controlling what identifier is passed to
#'   `.f`.
#'
#'   Must be one of:
#'
#'   * `"name"`: pass only the current leaf name or positional index;
#'   * `"path"`: pass the full path (vector of names) from the root to the current leaf.
#'
#' @return
#' A list with the same nested structure as `.x`, where each leaf has been
#' replaced by the result of calling `.f` on that leaf.
#'
#' @examples
#' \donttest{
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 2,
#'     y = list(i = 3, j = 4)
#'   ),
#'   unnamed = list(5, z = 6)
#' )
#'
#' # Pass only the leaf name or positional index
#' list_imap(x, \(value, name) paste(name, value, sep = " = "))
#'
#' # Pass the full path to each leaf
#' list_imap(
#'   x,
#'   \(value, path) paste(paste(path, collapse = "."), value, sep = " = "),
#'   .name = "path"
#' )
#'
#' # Additional arguments are forwarded to `.f`
#' list_imap(
#'   x,
#'   \(value, name, prefix) paste0(prefix, name, ": ", value),
#'   prefix = "leaf_"
#' )
#'
#' # Data frames are treated as leaves
#' x2 <- list(a = data.frame(x = 1:3), b = list(c = 1))
#' list_imap(x2, \(value, path) path, .name = "path")
#'
#' }
#' @family lstrrr-purrrlike
#' @export
list_imap <- function(
  .x,
  .f,
  ...,
  .name = c("name", "path"),
  .progress = FALSE
) {
  .name <- arg_match(.name)
  .f <- as_function(.f)

  total <- if (.list_progress_enabled(.progress)) {
    list_nleaf(.x)
  } else {
    0L
  }

  pb <- .list_progress_start(
    .progress = .progress,
    total = total
  )

  on.exit(.list_progress_done(pb), add = TRUE)

  if (.name == "path") {
    list_imap_path(.x = .x, .f = .f, ..., .pb = pb)
  } else {
    list_imap_name(.x = .x, .f = .f, ..., .pb = pb)
  }
}

list_imap_name <- function(.x, .f, ..., .name = character(0L), .pb = NULL) {
  if (is.list(.x) && !is.data.frame(.x)) {
    out <- vector("list", length(.x))
    names(out) <- names(.x)

    nms <- names(.x)

    for (i in seq_along(.x)) {
      key <- if (!is.null(nms) && nzchar(nms[[i]])) {
        nms[[i]]
      } else {
        as.character(i)
      }

      out[[i]] <- list_imap_name(
        .x[[i]],
        .f,
        ...,
        .name = key,
        .pb = .pb
      )
    }

    out
  } else {
    .list_progress_tick(.pb)
    .f(.x, .name, ...)
  }
}

list_imap_path <- function(.x, .f, ..., .path = character(0L), .pb = NULL) {
  if (is.list(.x) && !is.data.frame(.x)) {
    out <- vector("list", length(.x))
    names(out) <- names(.x)

    nms <- names(.x)

    for (i in seq_along(.x)) {
      key <- if (!is.null(nms) && nzchar(nms[[i]])) {
        nms[[i]]
      } else {
        as.character(i)
      }

      out[[i]] <- list_imap_path(
        .x[[i]],
        .f,
        ...,
        .path = c(.path, key),
        .pb = .pb
      )
    }

    out
  } else {
    .list_progress_tick(.pb)
    .f(.x, .path, ...)
  }
}

as_function <- function(.f, ...) {
  if (rlang::is_formula(.f)) {
    if (length(.f) != 2L) {
      cli::cli_abort(
        message = c("x" = "Formula must be one-sided, e.g. `~ .x + 1`."),
        call = rlang::caller_call(2L),
        .frame = rlang::caller_env(2L)
      )
    }
    rlang::as_function(.f)
  } else {
    match.fun(.f)
  }
}
