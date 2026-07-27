# test-list_core.R — tests for list_get, list_has, list_depth, list_path,
# list_set, list_delete, list_nleaf, list_find_value

# Shared test fixture ----------------------------------------------------------

x <- list(
  a = 1,
  b = list(
    x = 1,
    y = list(i = 1, j = 2)
  )
)

# list_get --------------------------------------------------------------------

test_that("list_get returns element at character path", {
  expect_identical(list_get(x, "a"), 1)
  expect_identical(list_get(x, c("b", "x")), 1)
  expect_identical(list_get(x, c("b", "y", "i")), 1)
  expect_identical(list_get(x, c("b", "y", "j")), 2)
})

test_that("list_get returns default for missing character path", {
  expect_identical(list_get(x, "z"), NULL)
  expect_identical(list_get(x, c("b", "z")), NULL)
  expect_identical(list_get(x, c("b", "y", "k")), NULL)
})

test_that("list_get uses custom default", {
  expect_identical(list_get(x, "z", default = 999), 999)
  expect_identical(
    list_get(x, c("b", "y", "k"), default = "missing"),
    "missing"
  )
})

test_that("list_get works with integer path", {
  y <- list(list(1, 2), list(3, 4))
  expect_identical(list_get(y, c(1L, 2L)), 2)
  expect_identical(list_get(y, c(2L, 1L)), 3)
})

test_that("list_get works with numeric path", {
  y <- list(list(1, 2), list(3, 4))
  expect_identical(list_get(y, c(1, 2)), 2)
})

test_that("list_get returns default for out-of-bounds integer path", {
  y <- list(list(1, 2))
  expect_identical(list_get(y, c(1L, 5L)), NULL)
  expect_identical(list_get(y, c(1L, 0L)), NULL)
  expect_identical(list_get(y, c(3L, 1L)), NULL)
})

test_that("list_get returns default for NA integer path", {
  y <- list(list(1, 2))
  expect_identical(list_get(y, c(1L, NA_integer_)), NULL)
})

test_that("list_get with empty path returns x itself", {
  expect_identical(list_get(x, character()), x)
})

test_that("list_get returns default when intermediate is not a list", {
  expect_identical(list_get(x, c("a", "x")), NULL)
})

test_that("list_get errors on invalid path type", {
  expect_snapshot(list_get(x, TRUE), error = TRUE)
})

# list_has --------------------------------------------------------------------

test_that("list_has returns TRUE for existing character path", {
  expect_true(list_has(x, "a"))
  expect_true(list_has(x, c("b", "x")))
  expect_true(list_has(x, c("b", "y", "i")))
  expect_true(list_has(x, c("b", "y", "j")))
})

test_that("list_has returns FALSE for missing character path", {
  expect_false(list_has(x, "z"))
  expect_false(list_has(x, c("b", "z")))
  expect_false(list_has(x, c("b", "y", "k")))
})

test_that("list_has works with integer path", {
  y <- list(list(1, 2), list(3, 4))
  expect_true(list_has(y, c(1L, 2L)))
  expect_false(list_has(y, c(1L, 5L)))
})

test_that("list_has works with numeric path", {
  y <- list(list(1, 2))
  expect_true(list_has(y, c(1, 2)))
})

test_that("list_has returns FALSE when intermediate is not a list", {
  expect_false(list_has(x, c("a", "x")))
})

test_that("list_has with empty path returns TRUE (x is valid)", {
  expect_true(list_has(x, character()))
})

test_that("list_has errors on invalid path type", {
  expect_snapshot(list_has(x, TRUE), error = TRUE)
})

# list_depth ------------------------------------------------------------------

test_that("list_depth returns correct depth for nested list", {
  expect_identical(list_depth(x), 3L)
})

test_that("list_depth returns 0 for an empty list", {
  expect_identical(list_depth(list()), 0L)
})

test_that("list_depth returns 1 for a flat list", {
  expect_identical(list_depth(list(a = 1, b = 2)), 1L)
})

test_that("list_depth returns 0 for a non-list (atomic)", {
  expect_identical(list_depth(1:5), 0L)
})

test_that("list_depth returns 0 for NULL", {
  expect_identical(list_depth(NULL), 0L)
})

test_that("list_depth handles deeply nested lists", {
  deep <- list(a = list(b = list(c = list(d = list(e = 1)))))
  expect_identical(list_depth(deep), 5L)
})

test_that("list_depth counts depth of deepest branch", {
  uneven <- list(
    a = 1,
    b = list(x = 1, y = list(i = 1, j = list(k = 2)))
  )
  expect_identical(list_depth(uneven), 4L)
})

test_that("list_depth does not recurse into data.frames", {
  lst <- list(a = iris[1:3, ])
  expect_identical(list_depth(lst), 1L)
})

# list_path -------------------------------------------------------------------

test_that("list_path returns all leaf paths as character vectors", {
  paths <- list_path(x)
  expect_type(paths, "list")
  expect_length(paths, 4L)
  expect_identical(paths[[1]], "a")
  expect_identical(paths[[2]], c("b", "x"))
  expect_identical(paths[[3]], c("b", "y", "i"))
  expect_identical(paths[[4]], c("b", "y", "j"))
})

test_that("list_path returns empty list for an empty list", {
  expect_identical(list_path(list()), list())
})

test_that("list_path returns list with empty path for NULL", {
  paths <- list_path(NULL)
  expect_type(paths, "list")
  expect_length(paths, 1L)
  expect_identical(paths[[1]], character())
})

test_that("list_path uses integer indices for unnamed elements", {
  y <- list(1, 2)
  paths <- list_path(y)
  expect_length(paths, 2L)
  expect_identical(paths[[1]], "1")
  expect_identical(paths[[2]], "2")
})

test_that("list_path handles mixed named/unnamed elements", {
  y <- list(a = 1, 2, c = 3)
  paths <- list_path(y)
  expect_length(paths, 3L)
  expect_identical(paths[[1]], "a")
  expect_identical(paths[[2]], "2")
  expect_identical(paths[[3]], "c")
})

test_that("list_path uses index for empty string names", {
  y <- stats::setNames(list(1, 2), c("a", ""))
  paths <- list_path(y)
  expect_identical(paths[[2]], "2")
})

test_that("list_path works with deeply nested structures", {
  deep <- list(a = list(b = list(c = 1, d = 2)))
  paths <- list_path(deep)
  expect_length(paths, 2L)
  expect_identical(paths[[1]], c("a", "b", "c"))
  expect_identical(paths[[2]], c("a", "b", "d"))
})

test_that("list_path does not recurse into data.frames", {
  lst <- list(a = 1, b = iris[1:2, ])
  paths <- list_path(lst)
  expect_length(paths, 2L)
  expect_identical(paths[[1]], "a")
  expect_identical(paths[[2]], "b")
})

test_that("list_path returns list with empty path for an atomic vector", {
  paths <- list_path(1:5)
  expect_type(paths, "list")
  expect_length(paths, 1L)
  expect_identical(paths[[1]], character())
})

# list_set --------------------------------------------------------------------

test_that("list_set updates existing value at character path", {
  result <- list_set(x, c("b", "x"), 99)
  expect_identical(list_get(result, c("b", "x")), 99)
})

test_that("list_set creates new intermediate nodes for missing character path", {
  result <- list_set(x, c("b", "z"), 42)
  expect_identical(list_get(result, c("b", "z")), 42)
})

test_that("list_set creates entire branch for fully missing path", {
  result <- list_set(x, c("c", "d"), 42)
  expect_identical(list_get(result, c("c", "d")), 42)
})

test_that("list_set with empty path returns value itself", {
  result <- list_set(x, character(), 999)
  expect_identical(result, 999)
})

test_that("list_set returns a new list (does not mutate original)", {
  orig <- list(a = 1)
  list_set(orig, "a", 999)
  expect_identical(orig, list(a = 1))
})

test_that("list_set works with integer path", {
  y <- list(list(1, 2), list(3, 4))
  result <- list_set(y, c(1L, 2L), 99)
  expect_identical(list_get(result, c(1L, 2L)), 99)
})

test_that("list_set with integer path creates intermediate nodes", {
  y <- list()
  result <- list_set(y, c(1L, 1L), 42)
  expect_identical(list_get(result, c(1L, 1L)), 42)
})

test_that("list_set with integer path extends list if needed", {
  y <- list(list(1))
  result <- list_set(y, c(2L, 1L), 42)
  expect_identical(list_get(result, c(2L, 1L)), 42)
})

test_that("list_set errors on invalid path type", {
  expect_snapshot(list_set(x, TRUE, 1), error = TRUE)
})

test_that("list_set with NA integer path errors", {
  y <- list(list(1, 2))
  expect_snapshot(list_set(y, c(1L, NA_integer_), 1), error = TRUE)
})

test_that("list_set with zero integer path errors", {
  y <- list(list(1, 2))
  expect_snapshot(list_set(y, c(1L, 0L), 1), error = TRUE)
})

test_that("list_set sets value at nested numeric path", {
  y <- list(list(1, 2), list(3, 4))
  result <- list_set(y, c(1, 2), 99)
  expect_identical(list_get(result, c(1, 2)), 99)
})

# list_delete -----------------------------------------------------------------

test_that("list_delete removes element at character path", {
  result <- list_delete(x, c("b", "y", "j"))
  expect_false(list_has(result, c("b", "y", "j")))
  expect_true(list_has(result, c("b", "y", "i")))
  expect_true(list_has(result, c("b", "x")))
})

test_that("list_delete returns x unchanged for missing character path", {
  result <- list_delete(x, c("b", "y", "k"))
  expect_identical(result, x)
})

test_that("list_delete returns x unchanged when intermediate is not a list", {
  result <- list_delete(x, c("a", "x"))
  expect_identical(result, x)
})

test_that("list_delete with empty path returns x unchanged", {
  result <- list_delete(x, character())
  expect_identical(result, x)
})

test_that("list_delete works with integer path", {
  y <- list(list(1, 2, 3), list(4, 5, 6))
  result <- list_delete(y, c(1L, 2L))
  expect_identical(list_get(result, 1L), list(1, 3))
})

test_that("list_delete with integer path returns x unchanged for out-of-bounds", {
  y <- list(list(1, 2))
  result <- list_delete(y, c(1L, 5L))
  expect_identical(result, y)
})

test_that("list_delete with integer path returns x unchanged for zero", {
  y <- list(list(1, 2))
  result <- list_delete(y, c(1L, 0L))
  expect_identical(result, y)
})

test_that("list_delete with integer path returns x unchanged for NA", {
  y <- list(list(1, 2))
  result <- list_delete(y, c(1L, NA_integer_))
  expect_identical(result, y)
})

test_that("list_delete works with numeric path", {
  y <- list(list(1, 2, 3))
  result <- list_delete(y, c(1, 2))
  expect_identical(list_get(result, 1L), list(1, 3))
})

test_that("list_delete errors on invalid path type", {
  expect_snapshot(list_delete(x, TRUE), error = TRUE)
})

test_that("list_delete returns a new list (does not mutate original)", {
  orig <- list(a = 1, b = 2)
  list_delete(orig, "a")
  expect_identical(orig, list(a = 1, b = 2))
})

test_that("list_delete removes top-level named element", {
  result <- list_delete(list(a = 1, b = 2), "a")
  expect_identical(result, list(b = 2))
})

test_that("list_delete handles removing only element", {
  result <- list_delete(list(a = 1), "a")
  expect_identical(result, structure(list(), names = character()))
})

# Integration: set then get ---------------------------------------------------

test_that("list_set followed by list_get returns the same value", {
  result <- list_set(x, c("b", "new_key"), 77)
  expect_identical(list_get(result, c("b", "new_key")), 77)
})

test_that("list_delete followed by list_get returns default", {
  result <- list_delete(x, c("b", "y", "j"))
  expect_identical(list_get(result, c("b", "y", "j")), NULL)
})

test_that("list_delete followed by list_has returns FALSE", {
  result <- list_delete(x, c("b", "y", "j"))
  expect_false(list_has(result, c("b", "y", "j")))
})

test_that("list_set a deleted key restores it", {
  deleted <- list_delete(x, c("b", "y", "j"))
  restored <- list_set(deleted, c("b", "y", "j"), 999)
  expect_identical(list_get(restored, c("b", "y", "j")), 999)
})

# list_nleaf -------------------------------------------------------------------

test_that("list_nleaf counts leaves correctly", {
  expect_identical(list_nleaf(x), 4L)
  expect_identical(list_nleaf(list()), 0L)
  expect_identical(list_nleaf(list(a = 1, b = 2)), 2L)
})

test_that("list_nleaf handles deeply nested lists", {
  deep <- list(a = list(b = list(c = 1, d = 2)))
  expect_identical(list_nleaf(deep), 2L)
})

# list_find_value --------------------------------------------------------------

test_that("list_find_value finds matching values", {
  x <- list(
    a = 1,
    b = list(c = 2, d = list(e = 1)),
    list(1)
  )

  paths <- list_find_value(x, 1)
  expect_type(paths, "list")
  expect_length(paths, 3L)
  expect_identical(paths[[1]], "a")
  expect_identical(paths[[2]], c("b", "d", "e"))
  expect_identical(paths[[3]], c("3", "1"))
})

test_that("list_find_value returns NULL when no match found", {
  x <- list(a = 1, b = list(c = 2))
  expect_null(list_find_value(x, 999))
})

test_that("list_find_value returns NULL for empty list", {
  expect_null(list_find_value(list(), 1))
})

test_that("list_find_value matches intermediate list nodes", {
  inner <- list(x = 1)
  x <- list(a = inner, b = 2)

  paths <- list_find_value(x, inner)
  expect_length(paths, 1L)
  expect_identical(paths[[1]], "a")
})

test_that("list_find_value uses identical() semantics", {
  x <- list(a = 1L, b = 1)

  paths <- list_find_value(x, 1L)
  expect_length(paths, 1L)
  expect_identical(paths[[1]], "a")
})

test_that("list_find_value works with character values", {
  x <- list(a = "hello", b = list(c = "hello", d = "world"))

  paths <- list_find_value(x, "hello")
  expect_length(paths, 2L)
  expect_identical(paths[[1]], "a")
  expect_identical(paths[[2]], c("b", "c"))
})

test_that("list_find_value works with NULL values", {
  x <- list(a = NULL, b = list(c = NULL))

  paths <- list_find_value(x, NULL)
  expect_length(paths, 2L)
  expect_identical(paths[[1]], "a")
  expect_identical(paths[[2]], c("b", "c"))
})

test_that("list_find_value works with logical values", {
  x <- list(a = TRUE, b = list(c = FALSE, d = TRUE))

  paths <- list_find_value(x, TRUE)
  expect_length(paths, 2L)
  expect_identical(paths[[1]], "a")
  expect_identical(paths[[2]], c("b", "d"))
})

test_that("list_find_value uses character keys for unnamed elements", {
  x <- list(list(1, list(1, 2)))

  paths <- list_find_value(x, 1)
  expect_length(paths, 2L)
  expect_identical(paths[[1]], c("1", "1"))
  expect_identical(paths[[2]], c("1", "2", "1"))
})

test_that("list_find_value finds multiple matches at same depth", {
  x <- list(a = 1, b = 1, c = list(d = 1))

  paths <- list_find_value(x, 1)
  expect_length(paths, 3L)
})

test_that("list_find_value handles deeply nested matches", {
  deep <- list(a = list(b = list(c = list(d = "target"))))
  paths <- list_find_value(deep, "target")
  expect_length(paths, 1L)
  expect_identical(paths[[1]], c("a", "b", "c", "d"))
})

test_that("list_find_value errors when x is not a list", {
  expect_error(list_find_value(1:5, 1))
})

test_that("list_find_value errors when x is a data.frame", {
  expect_error(list_find_value(data.frame(a = 1:3), 1))
})
