# nocov start

#' @title lstrrr
#'
#' @description Functional Tools for Working with Complex and Deeply Nested 'R' Lists
#'
#' @section License:
#' MIT + file LICENSE
#'
#' @docType package
#' @name lstrrr-package
#' @aliases lstrrr
#' @keywords internal
#'
"_PACKAGE"


.onAttach <- function(libname, pkgname) {
  pkg_version <- utils::packageVersion(pkgname)

  msg <- cli::cli_fmt(cli::cli_alert_success(
    text = c("v" = "{.pkg {pkgname}} v{pkg_version} loaded")
  ))
  packageStartupMessage(msg)
  invisible()
}

.onLoad <- function(libname, pkgname) {
  invisible()
}

## usethis namespace: start
#' @import rlang
#' @useDynLib lstrrr, .registration = TRUE
## usethis namespace: end
NULL

# nocov end
