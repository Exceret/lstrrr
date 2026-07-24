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
#' @param .progress Whether to show a progress
#'
#'   Use TRUE to turn on a basic progress, use a string to give it a name,
#'   or use a list to customize the progress bar (see `?cli::cli_progress_bar`
#'   and https://cli.r-lib.org/articles/progress-advanced.html#cli_progress_bar
#'   for details).
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

  .Call(
    "lstrrr_c_list_map",
    .x,
    .f,
    list(...),
    .progress,
    parent.frame(),
    PACKAGE = "lstrrr"
  )
}

#' Map over leaves of two nested lists
#'
#' @inheritParams list_map
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

  .Call(
    "lstrrr_c_list_map2",
    .x,
    .y,
    .f,
    list(...),
    .progress,
    parent.frame(),
    PACKAGE = "lstrrr"
  )
}

#' Map over leaves of multiple nested lists
#'
#' @inheritParams list_map
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

  .Call(
    "lstrrr_c_list_pmap",
    .l,
    .f,
    list(...),
    .progress,
    parent.frame(),
    PACKAGE = "lstrrr"
  )
}

#' Map over leaves with path (names)
#'
#' @inheritParams list_map
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
  .name <- rlang::arg_match(.name)
  .f <- as_function(.f)

  .Call(
    "lstrrr_c_list_imap",
    .x,
    .f,
    list(...),
    .name,
    .progress,
    parent.frame(),
    PACKAGE = "lstrrr"
  )
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
