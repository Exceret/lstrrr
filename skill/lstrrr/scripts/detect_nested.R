#!/usr/bin/env Rscript

# detect_nested.R — Step 0 of the lstrrr skill.
#
# Decide whether an R object is a *complex nested list*, i.e. the only kind of
# object the lstrrr toolkit is meant to be used on. A complex nested list is a
# list (never a data frame) whose depth is at least 2, meaning at least one list
# is nested inside another list.
#
# Usage:
#   Rscript detect_nested.R object.rds
#   Rscript detect_nested.R --expr "jsonlite::fromJSON('payload.json')"
#   Rscript detect_nested.R --file analysis.R --object cfg
#
# Exit status is always 0; read the `verdict:` line of the output.
#
# The script works whether or not lstrrr is installed: it prefers
# lstrrr::list_depth()/list_nleaf() and falls back to an equivalent base R
# implementation otherwise.

usage <- function() {
  cat(
    "Usage:\n",
    "  Rscript detect_nested.R <object.rds>\n",
    "  Rscript detect_nested.R --expr \"<R expression>\"\n",
    "  Rscript detect_nested.R --file <script.R> --object <name>\n",
    sep = ""
  )
  invisible(NULL)
}

args <- commandArgs(trailingOnly = TRUE)

if (!length(args)) {
  usage()
  quit(status = 1L)
}

# --- argument parsing ---------------------------------------------------------

rds_path <- NULL
expr_txt <- NULL
file_path <- NULL
object_name <- "x"

take_value <- function(args, i, flag) {
  if (i + 1L > length(args)) {
    stop("`", flag, "` requires a value.", call. = FALSE)
  }
  args[[i + 1L]]
}

i <- 1L
while (i <= length(args)) {
  arg <- args[[i]]

  if (arg %in% c("-h", "--help")) {
    usage()
    quit(status = 0L)
  } else if (arg == "--expr") {
    expr_txt <- take_value(args, i, "--expr")
    i <- i + 2L
  } else if (arg == "--file") {
    file_path <- take_value(args, i, "--file")
    i <- i + 2L
  } else if (arg == "--object") {
    object_name <- take_value(args, i, "--object")
    i <- i + 2L
  } else {
    rds_path <- arg
    i <- i + 1L
  }
}

# --- object loading -----------------------------------------------------------

env <- new.env(parent = globalenv())

if (!is.null(file_path)) {
  sys.source(file_path, envir = env)
}

obj <- if (!is.null(expr_txt)) {
  eval(parse(text = expr_txt), envir = env)
} else if (!is.null(file_path)) {
  if (!exists(object_name, envir = env, inherits = FALSE)) {
    stop("Object `", object_name, "` not found in ", file_path, ".", call. = FALSE)
  }
  get(object_name, envir = env, inherits = FALSE)
} else {
  if (is.null(rds_path) || !file.exists(rds_path)) {
    stop("File not found: ", rds_path, call. = FALSE)
  }
  readRDS(rds_path)
}

# --- structural diagnostics ---------------------------------------------------

is_node <- function(x) is.list(x) && !is.data.frame(x)

obj_type <- function(x) {
  if (is.null(x)) {
    "NULL"
  } else if (is.data.frame(x)) {
    "data.frame"
  } else if (is.list(x)) {
    "list"
  } else if (is.function(x)) {
    "function"
  } else {
    typeof(x)
  }
}

depth_of <- function(x) {
  if (!is_node(x)) return(0L)
  if (length(x) == 0L) return(1L)
  1L + max(vapply(x, depth_of, integer(1L)))
}

nleaf_of <- function(x) {
  if (!is_node(x)) return(1)
  if (length(x) == 0L) return(0)
  sum(vapply(x, nleaf_of, numeric(1L)))
}

nnode_of <- function(x) {
  if (!is_node(x)) return(1)
  if (length(x) == 0L) return(1)
  1L + sum(vapply(x, nnode_of, numeric(1L)))
}

leaf_types <- character()
has_null_leaf <- FALSE
has_empty_list <- FALSE
has_unnamed <- FALSE
max_breadth <- 0L

collect <- function(x) {
  if (!is_node(x)) {
    leaf_types <<- c(leaf_types, obj_type(x))
    if (is.null(x)) has_null_leaf <<- TRUE
    return(invisible(NULL))
  }

  if (length(x) == 0L) {
    has_empty_list <<- TRUE
    return(invisible(NULL))
  }

  max_breadth <<- max(max_breadth, length(x))

  nms <- names(x)
  if (is.null(nms) || any(is.na(nms) | !nzchar(nms))) {
    has_unnamed <<- TRUE
  }

  for (i in seq_along(x)) collect(x[[i]])

  invisible(NULL)
}

collect(obj)

paths_of <- function(x, prefix = character()) {
  if (!is_node(x)) {
    return(list(if (length(prefix)) paste(prefix, collapse = ".") else "(root)"))
  }
  if (length(x) == 0L) {
    return(list(paste(c(prefix, "<empty>"), collapse = ".")))
  }

  nms <- names(x)
  out <- list()

  for (i in seq_along(x)) {
    key <- if (!is.null(nms) && !is.na(nms[[i]]) && nzchar(nms[[i]])) {
      nms[[i]]
    } else {
      as.character(i)
    }
    out <- c(out, paths_of(x[[i]], c(prefix, key)))
  }

  out
}

use_lstrrr <- requireNamespace("lstrrr", quietly = TRUE)

depth <- if (use_lstrrr) as.integer(lstrrr::list_depth(obj)) else depth_of(obj)
n_leaf <- if (use_lstrrr) as.numeric(lstrrr::list_nleaf(obj)) else nleaf_of(obj)

is_list_like <- is.list(obj) && !is.data.frame(obj)
is_complex <- is_list_like && depth >= 2L

# --- report -------------------------------------------------------------------

emit <- function(key, value) cat(sprintf("%-16s %s\n", paste0(key, ":"), value))

emit("class", paste(class(obj), collapse = ", "))
emit("is_list", if (is_list_like) "TRUE" else "FALSE")
emit("depth", depth)
emit("n_leaf", format(n_leaf, scientific = FALSE))
emit("n_node", format(nnode_of(obj), scientific = FALSE))
emit("max_breadth", max_breadth)
emit("has_unnamed", if (has_unnamed) "TRUE" else "FALSE")
emit("has_null_leaf", if (has_null_leaf) "TRUE" else "FALSE")
emit("has_empty_list", if (has_empty_list) "TRUE" else "FALSE")
emit("leaf_types", paste(sort(unique(leaf_types)), collapse = ", "))

sample_paths <- if (is_list_like) head(paths_of(obj), 8L) else character()
if (length(sample_paths)) {
  cat("\nsample_paths:\n")
  for (p in sample_paths) cat("  - ", p, "\n", sep = "")
}

cat("\n")
emit("verdict", if (is_complex) "COMPLEX_NESTED_LIST" else "NOT_COMPLEX_NESTED_LIST")

if (is_complex) {
  cat("\nrecommendation: use lstrrr — pick the function from the task routing\n")
  cat("table in SKILL.md (see also references/api_reference.md).\n")
} else {
  cat("\nrecommendation: this object is NOT a complex nested list. Do not use\n")
  cat("lstrrr. Use purrr or base::lapply() instead:\n")

  if (!is_list_like) {
    cat("  - not a list: use vectorised code, vapply(), or dplyr verbs.\n")
  } else if (depth <= 1L) {
    cat("  - flat list (depth <= 1): use purrr::map() / purrr::imap() /\n")
    cat("    base::lapply(); purrr::map_dfr() when a data frame is wanted.\n")
  }
}

invisible(NULL)
