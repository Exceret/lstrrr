.list_is_nested <- function(x) {
  is.list(x) && !is.data.frame(x)
}

.list_obj_type <- function(x) {
  if (is.data.frame(x)) {
    "data.frame"
  } else if (is.list(x)) {
    "list"
  } else {
    typeof(x)
  }
}

.list_child_name <- function(x, i) {
  nms <- names(x)

  if (!is.null(nms) && !is.na(nms[[i]]) && nzchar(nms[[i]])) {
    nms[[i]]
  } else {
    as.character(i)
  }
}

.list_stats_add_node <- function(state, parent, name, path, depth, value) {
  id <- state$next_id

  node <- data.frame(
    id = id,
    parent = parent,
    name = name,
    type = .list_obj_type(value),
    path = paste(path, collapse = "."),
    depth = depth,
    is_leaf = !.list_is_nested(value),
    stringsAsFactors = FALSE
  )

  state$nodes[[length(state$nodes) + 1L]] <- node

  if (!is.na(parent)) {
    edge <- data.frame(
      from = parent,
      to = id,
      stringsAsFactors = FALSE
    )

    state$edges[[length(state$edges) + 1L]] <- edge
  }

  state$next_id <- id + 1L
  state$current_id <- id

  state
}

.list_stats_walk <- function(
  obj,
  name,
  path,
  depth,
  parent,
  state,
  max_depth = NULL
) {
  if (!is.null(max_depth) && depth > max_depth) {
    return(state)
  }

  state <- .list_stats_add_node(
    state = state,
    parent = parent,
    name = name,
    path = path,
    depth = depth,
    value = obj
  )

  this_id <- state$current_id

  if (.list_is_nested(obj)) {
    for (i in seq_along(obj)) {
      key <- .list_child_name(obj, i)

      state <- .list_stats_walk(
        obj = obj[[i]],
        name = key,
        path = c(path, key),
        depth = depth + 1L,
        parent = this_id,
        state = state,
        max_depth = max_depth
      )
    }
  }

  state
}

.list_empty_nodes <- function() {
  data.frame(
    id = integer(),
    parent = integer(),
    name = character(),
    type = character(),
    path = character(),
    depth = integer(),
    is_leaf = logical(),
    stringsAsFactors = FALSE
  )
}

.list_empty_edges <- function() {
  data.frame(
    from = integer(),
    to = integer(),
    stringsAsFactors = FALSE
  )
}

#' Convert a Nested List to Tree Data
#'
#' @param x A nested list.
#' @param max_depth Maximum depth to include. `NULL` means no limit.
#'
#' @return A list with `nodes` and `edges` data frames.
#'
#' @export
list_stats <- function(x, max_depth = NULL) {
  state <- list(
    next_id = 1L,
    current_id = NA_integer_,
    nodes = list(),
    edges = list()
  )

  state <- .list_stats_walk(
    obj = x,
    name = "root",
    path = "root",
    depth = 0L,
    parent = NA_integer_,
    state = state,
    max_depth = max_depth
  )

  nodes <- if (length(state$nodes)) {
    do.call(rbind, state$nodes)
  } else {
    .list_empty_nodes()
  }

  edges <- if (length(state$edges)) {
    do.call(rbind, state$edges)
  } else {
    .list_empty_edges()
  }

  list(
    nodes = nodes,
    edges = edges
  )
}
