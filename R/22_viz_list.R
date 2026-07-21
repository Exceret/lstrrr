.viz_list_make_label <- function(nodes, show_path = FALSE) {
  if (show_path) {
    paste0(nodes$path, "\n", "<", nodes$type, ">")
  } else {
    paste0(nodes$name, "\n", "<", nodes$type, ">")
  }
}

.viz_list_leaf_ids <- function(nodes, edges) {
  if (nrow(edges) == 0L) {
    return(nodes$id)
  }

  nodes$id[!nodes$id %in% edges$from]
}

.viz_list_assign_leaf_x <- function(nodes, edges) {
  x_pos <- rep(NA_real_, nrow(nodes))
  names(x_pos) <- as.character(nodes$id)

  leaf_ids <- .viz_list_leaf_ids(nodes, edges)

  for (i in seq_along(leaf_ids)) {
    x_pos[as.character(leaf_ids[[i]])] <- i
  }

  x_pos
}

.viz_list_assign_internal_x_one <- function(node_id, children, x_pos) {
  sid <- as.character(node_id)

  if (!is.na(x_pos[[sid]])) {
    return(list(value = x_pos[[sid]], x_pos = x_pos))
  }

  child_ids <- children[[sid]]

  vals <- numeric(length(child_ids))

  for (i in seq_along(child_ids)) {
    res <- .viz_list_assign_internal_x_one(
      node_id = child_ids[[i]],
      children = children,
      x_pos = x_pos
    )

    vals[[i]] <- res$value
    x_pos <- res$x_pos
  }

  x_pos[[sid]] <- mean(vals)

  list(
    value = x_pos[[sid]],
    x_pos = x_pos
  )
}

.viz_list_assign_x <- function(nodes, edges) {
  if (nrow(nodes) == 0L) {
    return(numeric())
  }

  x_pos <- .viz_list_assign_leaf_x(nodes, edges)

  children <- split(nodes$id, nodes$parent)
  children <- children[names(children) != "NA"]

  root_id <- nodes$id[[1L]]

  res <- .viz_list_assign_internal_x_one(
    node_id = root_id,
    children = children,
    x_pos = x_pos
  )

  unname(res$x_pos[as.character(nodes$id)])
}

.viz_list_add_edge_positions <- function(edges, nodes) {
  if (nrow(edges) == 0L) {
    edges$x <- numeric()
    edges$y <- numeric()
    edges$xend <- numeric()
    edges$yend <- numeric()
    return(edges)
  }

  edges$x <- nodes$x[match(edges$from, nodes$id)]
  edges$y <- nodes$y[match(edges$from, nodes$id)]
  edges$xend <- nodes$x[match(edges$to, nodes$id)]
  edges$yend <- nodes$y[match(edges$to, nodes$id)]

  edges
}

#' Visualize Nested List Structure
#'
#' Creates a tree-style visualization of the structure of a nested list using
#' ggplot2.
#'
#' @inheritParams list_map
#' @param max_depth Maximum depth to display.
#'
#'   A single non-negative integer or `NULL`. If `NULL`, the full nested
#'   structure is displayed. If supplied, only nodes with depth less than or
#'   equal to `max_depth` are included. This value is passed directly to
#'   [list_stats()].
#'
#' @param show_path Logical scalar.
#'
#'   If `FALSE`, node labels show the node's own name and type.
#'   If `TRUE`, node labels show the full path and type.
#'
#' @param point_size Numeric scalar giving the size of node points passed to
#'   [ggplot2::geom_point()].
#'
#' @param text_size Numeric scalar giving the size of node labels passed to
#'   [ggplot2::geom_text()].
#'
#' @param line_width Numeric scalar giving the width of edges passed to
#'   [ggplot2::geom_segment()].
#'
#' @return
#' A [ggplot2::ggplot] object representing the nested list as a tree diagram.
#'
#' The plot contains:
#'
#' * line segments for parent-child edges;
#' * points for nodes, colored by node type;
#' * text labels showing either node names or full paths plus node types;
#' * a y-axis labelled by list depth.
#'
#' @examples
#' \dontrun{
#' x <- list(
#'   a = 1,
#'   b = list(
#'     x = 2,
#'     y = list(i = 3, j = 4)
#'   ),
#'   c = data.frame(z = 1:3)
#' )
#'
#' # Visualize the full structure
#' viz_list(x)
#'
#' # Show full paths in node labels
#' viz_list(x, show_path = TRUE)
#'
#' # Limit the displayed depth
#' viz_list(x, max_depth = 1)
#'
#' # Customize appearance
#' viz_list(
#'   x,
#'   point_size = 4,
#'   text_size = 3.5,
#'   line_width = 1
#' )
#' }
#'
#' @seealso [list_stats()]
#' @family lstrrr-visualization
#' @export
viz_list <- function(
  x,
  max_depth = NULL,
  show_path = FALSE,
  point_size = 3L,
  text_size = 3L,
  line_width = 0.6
) {
  check_installed("ggplot2")

  tree <- list_stats(x, max_depth = max_depth)

  nodes <- tree$nodes
  edges <- tree$edges

  nodes$label <- .viz_list_make_label(nodes, show_path = show_path)
  nodes$x <- .viz_list_assign_x(nodes, edges)
  nodes$y <- -nodes$depth

  edges <- .viz_list_add_edge_positions(edges, nodes)

  # suppress NOTE
  y <- xend <- yend <- type <- label <- NULL # lintr: ignore
  ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = edges,
      ggplot2::aes(x = x, y = y, xend = xend, yend = yend),
      linewidth = line_width,
      color = "grey60"
    ) +
    ggplot2::geom_point(
      data = nodes,
      ggplot2::aes(x = x, y = y, color = type),
      size = point_size
    ) +
    ggplot2::geom_text(
      data = nodes,
      ggplot2::aes(x = x, y = y, label = label),
      size = text_size,
      vjust = -0.7,
      lineheight = 0.9
    ) +
    ggplot2::scale_y_continuous(
      breaks = sort(unique(nodes$y)),
      labels = abs(sort(unique(nodes$y)))
    ) +
    ggplot2::labs(
      x = NULL,
      y = "Depth",
      color = "Type"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank()
    )
}
