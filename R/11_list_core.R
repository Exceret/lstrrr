#' Get an element from a nested list by path
#'
#' @param x A nested list.
#' @param path Character or integer path.
#' @param default Value returned if path does not exist.
#' @export
list_get <- function(x, path, default = NULL) {
  .Call("lstrrr_c_list_get", x, path, default, PACKAGE = "lstrrr")
}

#' Check whether a path exists in a nested list
#'
#' @param x A nested list.
#' @param path Character or integer path.
#' @export
list_has <- function(x, path) {
  .Call("lstrrr_c_list_has", x, path, PACKAGE = "lstrrr")
}

#' Compute nested list depth
#'
#' @param x An object.
#' @export
list_depth <- function(x) {
  .Call("lstrrr_c_list_depth", x, PACKAGE = "lstrrr")
}

#' Get all leaf paths in a nested list
#'
#' @param x A nested list.
#' @export
list_path <- function(x) {
  .Call("lstrrr_c_list_path", x, PACKAGE = "lstrrr")
}


#' Set a nested element by path
#'
#' @param x A nested list.
#' @param path Character or integer path.
#' @param value Value to set.
#' @export
list_set <- function(x, path, value) {
  .Call("lstrrr_c_list_set", x, path, value, PACKAGE = "lstrrr")
}

#' Delete a nested element by path
#'
#' @param x A nested list.
#' @param path Character or integer path.
#' @export
list_delete <- function(x, path) {
  .Call("lstrrr_c_list_delete", x, path, PACKAGE = "lstrrr")
}
