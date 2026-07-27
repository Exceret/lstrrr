#' Get an element from a nested list by path
#'
#' @param x A nested list to traverse.
#'
#'   Lists are traversed recursively. Non-list objects are treated as leaves.
#'   Data frames are not traversed and are treated as leaf values.
#'
#' @param path Character or integer vector giving the path to retrieve.
#'
#'   For a character path, each component selects a named element at the current
#'   level. For an integer path, each component selects an element by position.
#'   Positional indices are one-based, following normal R indexing conventions.
#'
#'   The path is evaluated from left to right. For example,
#'   `c("b", "y", "i")` means `x[["b"]][["y"]][["i"]]`.
#'
#' @param default Value returned when the requested path does not exist or cannot
#'   be traversed.
#'
#'   The default is `NULL`.
#'
#' @family lstrrr_core
#'
#' @return
#' The value stored at `path`, or `default` if the path is missing or invalid.
#' @export
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   ),
#'   unnamed = list(10, 20),
#'   df = data.frame(z = 1:3)
#' )
#'
#' list_get(x, c("b", "x"))
#' list_get(x, c("b", "y", "i"))
#'
#' # Integer paths use positional indices
#' list_get(x, c(2L, 2L, 2L))
#'
#' # Missing paths return `default`
#' list_get(x, c("b", "missing"), default = NA)
#'
#' # Empty path returns the original object
#' list_get(x, character(0))
#'
#' # Data frames are treated as leaves
#' list_get(x, "df")
#' list_get(x, c("df", "z"), default = "not traversed")
#'
#'
list_get <- function(x, path, default = NULL) {
  .Call("lstrrr_c_list_get", x, path, default, PACKAGE = "lstrrr")
}

#' Check whether a path exists in a nested list
#'
#' @inheritParams list_get
#' @family lstrrr_core
#' @return
#' A logical scalar:
#'
#' * `TRUE` if `path` exists in `x`;
#' * `FALSE` otherwise.
#'
#' @export
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   ),
#'   unnamed = list(10, 20),
#'   df = data.frame(z = 1:3)
#' )
#'
#' list_has(x, c("b", "x"))
#' list_has(x, c("b", "y", "i"))
#' list_has(x, c("b", "y", "k"))
#'
#' # Integer paths use positional indices
#' list_has(x, c(2L, 2L, 1L))
#'
#' # Empty path refers to `x` itself, always returns TRUE
#' list_has(x, character(0))
#'
#' # Data frames are treated as leaves
#' list_has(x, "df")
#' list_has(x, c("df", "z")) # FALSE
#'
list_has <- function(x, path) {
  .Call("lstrrr_c_list_has", x, path, PACKAGE = "lstrrr")
}

#' Compute nested list depth
#'
#' @inheritParams list_get
#' @family lstrrr_core
#' @return
#' An integer scalar giving the maximum depth of `x`.
#'
#' A non-list leaf has depth `0`. A list containing only leaf values has depth
#' `1`. Deeper nested lists have larger depth according to the longest path to a
#' leaf.
#'
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   )
#' )
#'
#' list_depth(x)
#'
#' # A list with only leaf values has depth 1
#' list_depth(list(a = 1, b = 2))
#'
#' # Non-list objects are leaves
#' list_depth(1) # 0
#'
#' # Data frames are treated as leaves
#' list_depth(list(a = data.frame(x = 1:3)))
#'
#' list_depth(x) # 1
#'
#'
#' @export
list_depth <- function(x) {
  .Call("lstrrr_c_list_depth", x, PACKAGE = "lstrrr")
}

#' Get all leaf paths in a nested list
#'
#' @inheritParams list_get
#' @family lstrrr_core
#' @seealso [list_get()], [list_has()]
#' @return
#' A list of character vectors.
#'
#' Each element of the returned list is the path to one leaf value in `x`.
#' If `x` has no leaves, an empty list is returned.
#'
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   )
#' )
#'
#' res <- list_path(x)
#' res
#'
#' # The paths can be used with list_get()
#' lapply(res, \(path) list_get(x, path))
#'
#' # Top-level leaves have paths of length 1
#' list_path(list(a = 1, b = 2))
#'
#' # Unnamed elements use their position as character labels
#' list_path(list(10, list(20, z = 30)))
#'
#' # Data frames are treated as leaves
#' list_path(list(a = data.frame(x = 1:3), b = list(c = 1)))
#'
#'
#'
#' @export
list_path <- function(x) {
  .Call("lstrrr_c_list_path", x, PACKAGE = "lstrrr")
}


#' Set a nested element by path
#'
#' @inheritParams list_get
#' @param value Value to set at `path`.
#'
#'   This value replaces the existing element located at `path`. It may be any R
#'   object.
#'
#' @family lstrrr_core
#' @return
#' A modified copy of `x` with `value` assigned at `path`.
#'
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   )
#' )
#'
#' list_set(x, c("b", "x"), 2)
#'
#' # Set a deeply nested value
#' list_set(x, c("b", "y", "i"), 100)
#'
#' # Integer paths use positional indices
#' list_set(x, c(2L, 2L, 2L), 200)
#'
#' # Empty path replaces the whole object
#' list_set(x, character(0), "replacement")
#'
#' # The original object is unchanged unless reassigned
#' x2 <- list_set(x, c("b", "x"), 2)
#' x$b$x
#' x2$b$x
#'
#' @seealso [list_get()], [list_has()]
#' @export
list_set <- function(x, path, value) {
  .Call("lstrrr_c_list_set", x, path, value, PACKAGE = "lstrrr")
}

#' Delete a nested element by path
#'
#' @inheritParams list_get
#' @family lstrrr_core
#' @return
#' A modified copy of `x` with the element at `path` removed.
#'
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   )
#' )
#'
#' list_delete(x, c("b", "y", "j"))
#'
#' # Delete by integer path
#' list_delete(x, c(2L, 2L, 1L))
#'
#' # The original object is unchanged unless reassigned
#' x2 <- list_delete(x, c("b", "x"))
#' names(x$b)
#' names(x2$b)
#'
#' @seealso [list_get()], [list_has()], [list_set()]
#'
#' @export
list_delete <- function(x, path) {
  .Call("lstrrr_c_list_delete", x, path, PACKAGE = "lstrrr")
}


#' Count Leaf Nodes in a Nested List
#'
#' Count the number of leaf nodes in a nested list.
#'
#' @inheritParams list_get
#'
#' @return A numeric scalar. Integer when possible, double for very large counts.
#'
#' @examples
#' x <- list(a = 1, b = list(c = 2, d = list(e = 3)))
#' list_nleaf(x)
#'
#' list_nleaf(list())
#'
#' @family lstrrr_core
#' @export
list_nleaf <- function(x) {
  .Call("lstrrr_c_list_nleaf", x, PACKAGE = "lstrrr")
}


#' Find Paths Containing a Given Value
#'
#' Traverse a nested list and return all paths whose element is identical
#' to `value`.
#'
#' @inheritParams list_get
#' @param value Value to find.
#'
#' @return A list of character vectors, or `NULL` if no match is found.
#'
#' @examples
#' x <- list(
#'   a = 1,
#'   b = list(c = 2, d = list(e = 1)),
#'   list(1)
#' )
#'
#' list_find_value(x, 1)
#' @family lstrrr_core
#' @export
list_find_value <- function(x, value) {
  .Call("lstrrr_c_list_find_val", x, value, PACKAGE = "lstrrr")
}
