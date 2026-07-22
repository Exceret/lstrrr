# test-viz_list.R — tests for viz_list

skip_if_not_installed("ggplot2")

# Shared test fixture ----------------------------------------------------------

x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  ),
  c = data.frame(z = 1:3)
)

# Return value -----------------------------------------------------------------

test_that("viz_list returns a ggplot object", {
  p <- viz_list(x)
  expect_s3_class(p, "ggplot")
})

test_that("viz_list returns a ggplot with correct layers", {
  p <- viz_list(x)
  # Should have geom_segment, geom_point, geom_text layers
  classes <- vapply(p$layers, function(l) class(l$geom)[1L], character(1L))
  expect_contains(classes, "GeomSegment")
  expect_contains(classes, "GeomPoint")
  expect_contains(classes, "GeomText")
})

# show_path --------------------------------------------------------------------

test_that("viz_list with show_path = FALSE shows node names", {
  p <- viz_list(x, show_path = FALSE)
  # Just check it doesn't error
  expect_s3_class(p, "ggplot")
})

test_that("viz_list with show_path = TRUE shows full paths", {
  p <- viz_list(x, show_path = TRUE)
  expect_s3_class(p, "ggplot")
})

# max_depth --------------------------------------------------------------------

test_that("viz_list with max_depth = 0 works", {
  p <- viz_list(x, max_depth = 0L)
  expect_s3_class(p, "ggplot")
})

test_that("viz_list with max_depth = 1 works", {
  p <- viz_list(x, max_depth = 1L)
  expect_s3_class(p, "ggplot")
})

test_that("viz_list with max_depth = NULL shows full tree", {
  p <- viz_list(x, max_depth = NULL)
  expect_s3_class(p, "ggplot")
})

# Customization parameters -----------------------------------------------------

test_that("viz_list accepts custom point_size", {
  p <- viz_list(x, point_size = 5)
  expect_s3_class(p, "ggplot")
})

test_that("viz_list accepts custom text_size", {
  p <- viz_list(x, text_size = 4)
  expect_s3_class(p, "ggplot")
})

test_that("viz_list accepts custom line_width", {
  p <- viz_list(x, line_width = 1.5)
  expect_s3_class(p, "ggplot")
})

# Edge cases -------------------------------------------------------------------

test_that("viz_list on empty list works", {
  p <- viz_list(list())
  expect_s3_class(p, "ggplot")
})

test_that("viz_list on NULL works", {
  p <- viz_list(NULL)
  expect_s3_class(p, "ggplot")
})

test_that("viz_list on flat list works", {
  p <- viz_list(list(a = 1, b = 2))
  expect_s3_class(p, "ggplot")
})

test_that("viz_list on deeply nested list works", {
  deep <- list(a = list(b = list(c = list(d = 1))))
  p <- viz_list(deep)
  expect_s3_class(p, "ggplot")
})

test_that("viz_list with unnamed elements works", {
  p <- viz_list(list(1, 2, list(3, 4)))
  expect_s3_class(p, "ggplot")
})

test_that("viz_list with data.frame leaf works", {
  p <- viz_list(list(df = iris[1:3, ]))
  expect_s3_class(p, "ggplot")
})

# Internal helpers -------------------------------------------------------------

test_that(".viz_list_make_label with show_path = FALSE returns name + type", {
  nodes <- data.frame(
    name = "a",
    type = "double",
    path = "root.a",
    stringsAsFactors = FALSE
  )
  label <- .viz_list_make_label(nodes, show_path = FALSE)
  expect_match(label, "a")
  expect_match(label, "<double>")
})

test_that(".viz_list_make_label with show_path = TRUE returns path + type", {
  nodes <- data.frame(
    name = "a",
    type = "double",
    path = "root.a",
    stringsAsFactors = FALSE
  )
  label <- .viz_list_make_label(nodes, show_path = TRUE)
  expect_match(label, "root\\.a")
  expect_match(label, "<double>")
})

test_that(".viz_list_leaf_ids returns all ids when no edges", {
  nodes <- data.frame(id = 1:3, stringsAsFactors = FALSE)
  edges <- data.frame(from = integer(), to = integer())
  leaf_ids <- .viz_list_leaf_ids(nodes, edges)
  expect_equal(leaf_ids, 1:3)
})

test_that(".viz_list_leaf_ids excludes parent ids", {
  nodes <- data.frame(id = 1:3, stringsAsFactors = FALSE)
  edges <- data.frame(from = c(1L, 1L), to = c(2L, 3L))
  leaf_ids <- .viz_list_leaf_ids(nodes, edges)
  expect_equal(leaf_ids, c(2L, 3L))
})

test_that(".viz_list_assign_leaf_x assigns sequential x to leaves", {
  nodes <- data.frame(id = 1:3, stringsAsFactors = FALSE)
  edges <- data.frame(from = 1L, to = c(2L, 3L))
  x_pos <- .viz_list_assign_leaf_x(nodes, edges)
  # Leaves 2 and 3 get positions 1 and 2, internal node 1 gets NA
  expect_equal(unname(x_pos), c(NA_real_, 1, 2))
})

test_that(".viz_list_assign_x returns correct positions for simple tree", {
  tree <- list_stats(list(a = 1, b = 2))
  nodes <- tree$nodes
  edges <- tree$edges
  x_pos <- .viz_list_assign_x(nodes, edges)
  expect_length(x_pos, nrow(nodes))
  expect_true(all(!is.na(x_pos)))
})

test_that(".viz_list_assign_x with empty nodes returns empty numeric", {
  nodes <- data.frame(
    id = integer(),
    parent = integer(),
    name = character(),
    type = character(),
    path = character(),
    depth = integer(),
    is_leaf = logical(),
    stringsAsFactors = FALSE
  )
  edges <- data.frame(from = integer(), to = integer())
  x_pos <- .viz_list_assign_x(nodes, edges)
  expect_identical(x_pos, numeric())
})

test_that(".viz_list_add_edge_positions adds x/y/xend/yend columns", {
  tree <- list_stats(list(a = 1, b = 2))
  nodes <- tree$nodes
  nodes$x <- c(1.5, 1, 2)
  nodes$y <- c(0, -1, -1)
  edges <- tree$edges

  result <- .viz_list_add_edge_positions(edges, nodes)
  expect_named(result, c("from", "to", "x", "y", "xend", "yend"))
  expect_true(all(!is.na(result$x)))
  expect_true(all(!is.na(result$yend)))
})

test_that(".viz_list_add_edge_positions with empty edges returns empty columns", {
  nodes <- data.frame(
    id = 1L,
    parent = NA_integer_,
    name = "root",
    type = "list",
    path = "root",
    depth = 0L,
    is_leaf = FALSE,
    x = 1,
    y = 0,
    stringsAsFactors = FALSE
  )
  edges <- data.frame(from = integer(), to = integer())

  result <- .viz_list_add_edge_positions(edges, nodes)
  expect_equal(nrow(result), 0L)
  expect_named(result, c("from", "to", "x", "y", "xend", "yend"))
})
