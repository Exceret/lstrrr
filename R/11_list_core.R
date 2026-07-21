#' Get an element from a nested list by path
#'
#' @param x A nested list.
#' @param path Character or integer path.
#' @param default Value returned if path does not exist.
#'
#' @family lstrrr_core
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
#'
#' list_get(x, c("b", "x")) # 1
#' list_get(x, c("b", "y", "i")) # 1
#' }
#'
#' @export
list_get <- function(x, path, default = NULL) {
  .Call("lstrrr_c_list_get", x, path, default, PACKAGE = "lstrrr")
}

#' Check whether a path exists in a nested list
#'
#' @param x A nested list.
#' @param path Character or integer path.
#' @family lstrrr_core
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
#'
#' list_has(x, c("b", "x")) # TRUE
#' list_has(x, c("b", "y", "i")) # TRUE
#' list_has(x, c("b", "y", "k")) # FALSE
#' }
#'
#' @export
list_has <- function(x, path) {
  .Call("lstrrr_c_list_has", x, path, PACKAGE = "lstrrr")
}

#' Compute nested list depth
#'
#' @param x An list object.
#' @family lstrrr_core
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
#'
#' list_depth(x) # 3
#' }
#'
#' @export
list_depth <- function(x) {
  .Call("lstrrr_c_list_depth", x, PACKAGE = "lstrrr")
}

#' Get all leaf paths in a nested list
#'
#' @param x A nested list.
#' @family lstrrr_core
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
#' res <- list_path(x)
#' # [[1]]
#' # [1] "a" # character
#' #
#' # [[2]]
#' # [1] "b" "x"
#' #
#' # [[3]]
#' # [1] "b" "y" "i"
#' #
#' # [[4]]
#' # [1] "b" "y" "j"
#' class(res) # "list"
#' }
#'
#' @export
list_path <- function(x) {
  .Call("lstrrr_c_list_path", x, PACKAGE = "lstrrr")
}


#' Set a nested element by path
#'
#' @param x A nested list.
#' @param path Character or integer path.
#' @param value Value to set.
#' @family lstrrr_core
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
#' list_set(x, c("b", "x"), 2)
#' # $a
#' # [1] 1
#' #
#' # $b
#' # $b$x
#' # [1] 2 # <<< CHANGE
#' #
#' # $b$y
#' # $b$y$i
#' # [1] 1
#' #
#' # $b$y$j
#' # [1] 2
#' #
#' }
#' @export
list_set <- function(x, path, value) {
  .Call("lstrrr_c_list_set", x, path, value, PACKAGE = "lstrrr")
}

#' Delete a nested element by path
#'
#' @param x A nested list.
#' @param path Character or integer path.
#' @family lstrrr_core
#' @examples
#' \donttest{
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 1,
#'     y = list(i = 1, j = 2)
#'   )
#' )
#' list_delete(x, c("b", "y", "j"))
#' # $a
#' # [1] 1
#' #
#' # $b
#' # $b$y
#' # $b$y$i
#' # [1] 1
#' }
#'
#' @export
list_delete <- function(x, path) {
  .Call("lstrrr_c_list_delete", x, path, PACKAGE = "lstrrr")
}
