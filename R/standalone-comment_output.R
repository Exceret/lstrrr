# ---
# repo: Exceret/lstrrr
# file: standalone-comment_output.R
# last-updated: 2026-07-20
# license: https://unlicense.org
# imports: [rlang]
# ---
#
# This file provides a function to add comments prefix to the output of an expression.
#
# nocov start

#' Add comments prefix to the output of an expression.
#' @param expr The expression to evaluate.
#' @param prefix The prefix to add to the output.
#' @noRd
comment_output <- function(expr, prefix = c("#", "#'", "#' #")) {
  prefix <- arg_match(prefix)

  quo <- enquo(expr)

  out <- utils::capture.output(
    eval_tidy(quo)
  )

  if (length(out) > 0) {
    message(paste0(prefix, " ", out, collapse = "\n"))
  }

  invisible(out)
}

# nocov end
