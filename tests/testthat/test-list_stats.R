# test-list_stats.R — tests for list_stats

# Shared test fixture ----------------------------------------------------------

x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  ),
  c = data.frame(z = 1:3)
)

# Core structure ---------------------------------------------------------------

test_that("list_stats returns a list with nodes and edges", {
  result <- list_stats(x)
  expect_type(result, "list")
  expect_named(result, c("nodes", "edges"))
  expect_s3_class(result$nodes, "data.frame")
  expect_s3_class(result$edges, "data.frame")
})

test_that("list_stats nodes have correct columns", {
  result <- list_stats(x)
  expect_named(
    result$nodes,
    c("id", "parent", "name", "type", "path", "depth", "is_leaf")
  )
})

test_that("list_stats edges have correct columns", {
  result <- list_stats(x)
  expect_named(result$edges, c("from", "to"))
})

test_that("list_stats root node has parent NA and depth 0", {
  result <- list_stats(x)
  root <- result$nodes[result$nodes$depth == 0L, ]
  expect_equal(nrow(root), 1L)
  expect_identical(root$name, "root")
  expect_true(is.na(root$parent))
  expect_identical(root$path, "root")
})

test_that("list_stats assigns sequential IDs", {
  result <- list_stats(x)
  ids <- result$nodes$id
  expect_equal(ids, seq_along(ids))
})

# Node types -------------------------------------------------------------------

test_that("list_stats labels list nodes as 'list'", {
  result <- list_stats(x)
  list_nodes <- result$nodes[result$nodes$type == "list", ]
  expect_true(nrow(list_nodes) > 0L)
})

test_that("list_stats labels data.frame nodes as 'data.frame'", {
  result <- list_stats(x)
  df_nodes <- result$nodes[result$nodes$type == "data.frame", ]
  expect_true(nrow(df_nodes) >= 1L)
})

test_that("list_stats labels atomic leaves with typeof", {
  result <- list_stats(list(a = 1L, b = 1.5, c = "text", d = TRUE))
  types <- result$nodes$type[result$nodes$is_leaf]
  expect_contains(types, "integer")
  expect_contains(types, "double")
  expect_contains(types, "character")
  expect_contains(types, "logical")
})

# is_leaf ----------------------------------------------------------------------

test_that("list_stats marks non-list leaves as is_leaf = TRUE", {
  result <- list_stats(x)
  leaves <- result$nodes[result$nodes$is_leaf, ]
  expect_true(all(!leaves$type %in% "list"))
})

test_that("list_stats marks list nodes as is_leaf = FALSE", {
  result <- list_stats(x)
  list_nodes <- result$nodes[result$nodes$type == "list", ]
  expect_true(all(!list_nodes$is_leaf))
})

# Depth ------------------------------------------------------------------------

test_that("list_stats tracks correct depths", {
  result <- list_stats(x)
  # root=0, a/c/b=1, b/x/b/y=2, b/y/i/b/y/j=3
  depths <- result$nodes$depth
  expect_equal(min(depths), 0L)
  expect_equal(max(depths), 3L)
})

# Unnamed elements -------------------------------------------------------------

test_that("list_stats uses positional index for unnamed elements", {
  result <- list_stats(list(10, 20))
  names <- result$nodes$name[result$nodes$depth == 1L]
  expect_equal(names, c("1", "2"))
})

test_that("list_stats uses empty-string name as positional index", {
  result <- list_stats(stats::setNames(list(1, 2), c("a", "")))
  names <- result$nodes$name[result$nodes$depth == 1L]
  expect_equal(names, c("a", "2"))
})

# max_depth --------------------------------------------------------------------

test_that("list_stats respects max_depth = 0", {
  result <- list_stats(x, max_depth = 0L)
  expect_equal(nrow(result$nodes), 1L)
  expect_equal(nrow(result$edges), 0L)
})

test_that("list_stats respects max_depth = 1", {
  result <- list_stats(x, max_depth = 1L)
  depths <- result$nodes$depth
  expect_true(all(depths <= 1L))
  # Should have root + depth-1 children
  expect_true(nrow(result$nodes) > 1L)
})

test_that("list_stats with max_depth truncates but marks truncated nodes correctly", {
  # At max_depth, a list node won't be recursed into but should be marked
  # as a node (is_leaf depends on whether it's a list)
  result <- list_stats(x, max_depth = 1L)
  # b is a list at depth 1, truncated at max_depth=1
  b_node <- result$nodes[result$nodes$name == "b" & result$nodes$depth == 1L, ]
  expect_equal(nrow(b_node), 1L)
  # Since b is a list, is_leaf should be FALSE
  expect_false(b_node$is_leaf)
})

# Edges ------------------------------------------------------------------------

test_that("list_stats edges connect parent to child by id", {
  result <- list_stats(list(a = 1, b = 2))
  expect_equal(nrow(result$edges), 2L)
  # root id should be 1
  root_id <- result$nodes$id[result$nodes$depth == 0L]
  expect_equal(result$edges$from, c(root_id, root_id))
})

test_that("list_stats edges for deep structure are correct", {
  result <- list_stats(list(a = list(b = 1)))
  # root -> a -> b (3 nodes, 2 edges)
  expect_equal(nrow(result$nodes), 3L)
  expect_equal(nrow(result$edges), 2L)
})

# Edge cases -------------------------------------------------------------------

test_that("list_stats on empty list returns root node only", {
  result <- list_stats(list())
  expect_equal(nrow(result$nodes), 1L)
  expect_equal(nrow(result$edges), 0L)
  expect_identical(result$nodes$name, "root")
})

test_that("list_stats on NULL returns root node only", {
  result <- list_stats(NULL)
  expect_equal(nrow(result$nodes), 1L)
  expect_equal(nrow(result$edges), 0L)
})

test_that("list_stats on atomic vector returns root node only", {
  result <- list_stats(1:5)
  expect_equal(nrow(result$nodes), 1L)
  expect_equal(nrow(result$edges), 0L)
  expect_identical(result$nodes$type, "integer")
})

test_that("list_stats handles NULL leaf values", {
  result <- list_stats(list(a = NULL, b = 1))
  expect_true(any(result$nodes$name == "a"))
  expect_true(any(result$nodes$name == "b"))
})

test_that("list_stats handles deeply nested structure", {
  deep <- list(a = list(b = list(c = list(d = 1))))
  result <- list_stats(deep)
  expect_equal(max(result$nodes$depth), 4L)
})

test_that("list_stats node count equals edges + 1 (tree property)", {
  result <- list_stats(x)
  expect_equal(nrow(result$nodes), nrow(result$edges) + 1L)
})

# Path construction ------------------------------------------------------------

test_that("list_stats paths are dot-separated", {
  result <- list_stats(x)
  paths <- result$nodes$path
  expect_match(paths[1L], "root")
  # A leaf path should be like "root.b.y.i"
  leaf_paths <- paths[result$nodes$is_leaf]
  expect_true(any(grepl("^root\\.", leaf_paths)))
})
