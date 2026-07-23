#' Convert File Paths to a Nested List
#'
#' Convert character paths, usually returned by [list.files()],
#' to a nested list structure.
#'
#' @param paths A character vector of file paths.
#' @param value What to store at leaf nodes. One of `"path"`, `"name"`,
#'   or `"TRUE"`.
#' @param sep Path separator (regex). Defaults to `/` and `\\`.
#' @param simplify_empty Logical. If `TRUE`, empty path components are removed.
#'
#' @return A nested named list.
#'
#' @examples
#' \donttest{
#' paths <- c(
#'   "R/list-core.R",
#'   "R/viz-list.R",
#'   "src/init.c",
#'   "src/list_core.c",
#'   "DESCRIPTION"
#' )
#'
#' dir_listwise(paths)
#' }
#'
#' @export
dir_listwise <- function(
  paths,
  value = c("path", "name", "TRUE"),
  sep = "[/\\\\]+",
  simplify_empty = TRUE
) {
  value <- match.arg(value)

  if (!is.character(paths)) {
    cli::cli_abort(
      "{.arg paths} must be a {.cls character vector}.",
      call = caller_call(),
      .frame = caller_env()
    )
  }

  paths <- paths[!is.na(paths)]

  out <- list()

  for (path in paths) {
    parts <- strsplit(path, sep, perl = TRUE)[[1L]]

    if (simplify_empty) {
      parts <- parts[nzchar(parts)]
    }

    if (!length(parts)) {
      next
    }

    leaf_value <- switch(
      value,
      path = path,
      name = parts[[length(parts)]],
      TRUE ~ TRUE
    )

    out <- list_set(out, parts, leaf_value)
  }

  out
}
