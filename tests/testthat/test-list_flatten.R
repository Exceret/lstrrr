# test-list_flatten.R — tests for list_flatten and list_find

# Shared test fixture ----------------------------------------------------------

x <- list(
  a = 1,
  b = list(
    x = 1,
    y = list(i = 1, j = 2)
  )
)

# list_flatten ----------------------------------------------------------------

test_that("list_flatten returns a flat named list", {
  result <- list_flatten(x)
  expect_type(result, "list")
  expect_named(result, c("a", "b.x", "b.y.i", "b.y.j"))
  expect_identical(result[["a"]], 1)
  expect_identical(result[["b.x"]], 1)
  expect_identical(result[["b.y.i"]], 1)
  expect_identical(result[["b.y.j"]], 2)
})

test_that("list_flatten uses custom separator", {
  result <- list_flatten(x, sep = "/")
  expect_named(result, c("a", "b/x", "b/y/i", "b/y/j"))
})

test_that("list_flatten with empty separator concatenates names directly", {
  result <- list_flatten(x, sep = "")
  expect_named(result, c("a", "bx", "byi", "byj"))
})

test_that("list_flatten with multi-char separator", {
  result <- list_flatten(x, sep = " -> ")
  expect_named(result, c("a", "b -> x", "b -> y -> i", "b -> y -> j"))
})

test_that("list_flatten on empty list returns empty list", {
  expect_identical(list_flatten(list()), structure(list(), names = character()))
})

test_that("list_flatten on flat list returns same list with names", {
  result <- list_flatten(list(a = 1, b = 2))
  expect_identical(result, list(a = 1, b = 2))
})

test_that("list_flatten on NULL returns list with NULL at empty-name", {
  result <- list_flatten(NULL)
  expect_type(result, "list")
  expect_length(result, 1L)
  expect_named(result, "")
  expect_null(result[[1]])
})

test_that("list_flatten uses integer indices for unnamed elements", {
  y <- list(1, 2)
  result <- list_flatten(y)
  expect_named(result, c("1", "2"))
  expect_identical(result[["1"]], 1)
  expect_identical(result[["2"]], 2)
})

test_that("list_flatten handles mixed named/unnamed elements", {
  y <- list(a = 1, 2, c = 3)
  result <- list_flatten(y)
  expect_named(result, c("a", "2", "c"))
})

test_that("list_flatten handles nested unnamed lists", {
  y <- list(list(1, 2), list(3, 4))
  result <- list_flatten(y)
  expect_named(result, c("1.1", "1.2", "2.1", "2.2"))
})

test_that("list_flatten uses index for empty string names", {
  y <- stats::setNames(list(1, 2), c("a", ""))
  result <- list_flatten(y)
  expect_named(result, c("a", "2"))
})

test_that("list_flatten treats data.frames as leaf values", {
  lst <- list(a = 1, b = iris[1:2, ])
  result <- list_flatten(lst)
  expect_named(result, c("a", "b"))
  expect_identical(result[["a"]], 1)
  expect_identical(result[["b"]], iris[1:2, ])
})

test_that("list_flatten handles deeply nested structure", {
  deep <- list(a = list(b = list(c = list(d = list(e = 1)))))
  result <- list_flatten(deep)
  expect_named(result, "a.b.c.d.e")
  expect_identical(result[["a.b.c.d.e"]], 1)
})

test_that("list_flatten preserves leaf types", {
  y <- list(
    int = 1L,
    dbl = 1.5,
    chr = "hello",
    lgl = TRUE,
    cmp = 1 + 2i
  )
  result <- list_flatten(y)
  expect_type(result[["int"]], "integer")
  expect_type(result[["dbl"]], "double")
  expect_type(result[["chr"]], "character")
  expect_type(result[["lgl"]], "logical")
  expect_type(result[["cmp"]], "complex")
})

test_that("list_flatten preserves NULL leaf values", {
  y <- list(a = NULL, b = list(c = NULL))
  result <- list_flatten(y)
  expect_named(result, c("a", "b.c"))
  expect_null(result[["a"]])
  expect_null(result[["b.c"]])
})

test_that("list_flatten with multiple leaf types in nested structure", {
  y <- list(
    a = 1,
    b = list(x = TRUE, y = list(i = "text", j = 3.14))
  )
  result <- list_flatten(y)
  expect_identical(result[["a"]], 1)
  expect_identical(result[["b.x"]], TRUE)
  expect_identical(result[["b.y.i"]], "text")
  expect_identical(result[["b.y.j"]], 3.14)
})

test_that("list_flatten errors on non-string sep", {
  expect_snapshot(list_flatten(x, sep = 1), error = TRUE)
})

test_that("list_flatten errors on sep of length > 1", {
  expect_snapshot(list_flatten(x, sep = c(".", "-")), error = TRUE)
})

test_that("list_flatten returns atomic vector as single leaf with empty name", {
  result <- list_flatten(1:5)
  expect_type(result, "list")
  expect_length(result, 1L)
  expect_named(result, "")
  expect_identical(result[[1]], 1:5)
})

# list_find -------------------------------------------------------------------

test_that("list_find returns leaves matching predicate", {
  result <- list_find(x, ~ .x == 1)
  expect_type(result, "list")
  expect_named(result, c("a", "b.x", "b.y.i"))
  expect_identical(result[["a"]], 1)
  expect_identical(result[["b.x"]], 1)
  expect_identical(result[["b.y.i"]], 1)
})

test_that("list_find with formula predicate", {
  result <- list_find(x, ~ .x > 1)
  expect_named(result, "b.y.j")
  expect_identical(result[["b.y.j"]], 2)
})

test_that("list_find with function predicate", {
  result <- list_find(x, function(value) value == 2)
  expect_named(result, "b.y.j")
  expect_identical(result[["b.y.j"]], 2)
})

test_that("list_find returns empty list when nothing matches", {
  result <- list_find(x, ~ .x > 999)
  expect_identical(result, structure(list(), names = character()))
})

test_that("list_find on empty list returns empty list", {
  result <- list_find(list(), ~ .x > 0)
  expect_identical(result, structure(list(), names = character()))
})

test_that("list_find on NULL returns empty list", {
  result <- list_find(NULL, ~ .x > 0)
  expect_identical(result, structure(list(), names = character()))
})

test_that("list_find with identity predicate", {
  result <- list_find(x, ~ TRUE)
  expect_named(result, c("a", "b.x", "b.y.i", "b.y.j"))
  expect_length(result, 4L)
})

test_that("list_find with always-false predicate", {
  result <- list_find(x, ~ FALSE)
  expect_length(result, 0L)
})

test_that("list_find ignores NA results from predicate (isTRUE)", {
  result <- list_find(x, ~ NA)
  expect_length(result, 0L)
})

test_that("list_find ignores non-logical results from predicate", {
  result <- list_find(x, ~ "not_logical")
  expect_length(result, 0L)
})

test_that("list_find works with deeply nested structure", {
  deep <- list(a = list(b = list(c = 1, d = 2), e = 3), f = 4)
  result <- list_find(deep, ~ .x > 1)
  expect_named(result, c("a.b.d", "a.e", "f"))
})

test_that("list_find with multiple leaf types", {
  y <- list(
    a = 1,
    b = list(x = TRUE, y = list(i = "text", j = 3.14))
  )
  result <- list_find(y, is.numeric)
  expect_named(result, c("a", "b.y.j"))
  expect_identical(result[["a"]], 1)
  expect_identical(result[["b.y.j"]], 3.14)
})

test_that("list_find with is.character predicate", {
  y <- list(a = "hello", b = list(c = "world", d = 1))
  result <- list_find(y, is.character)
  expect_named(result, c("a", "b.c"))
})

test_that("list_find treats data.frames as leaf values", {
  lst <- list(a = 1, b = iris[1:2, ], c = list(d = 2))
  result <- list_find(lst, is.data.frame)
  expect_named(result, "b")
  expect_identical(result[["b"]], iris[1:2, ])
})

test_that("list_find preserves NULL leaf values when matched", {
  y <- list(a = NULL, b = list(c = 1))
  result <- list_find(y, is.null)
  expect_named(result, "a")
  expect_null(result[["a"]])
})

test_that("list_find with unnamed nested elements", {
  y <- list(list(1, 2), list(3, 4))
  result <- list_find(y, ~ .x > 2)
  expect_named(result, c("2.1", "2.2"))
})

test_that("list_find errors on two-sided formula", {
  expect_snapshot(list_find(x, y ~ x + 1), error = TRUE)
})

test_that("list_find errors when .p is not coercible to function", {
  expect_snapshot(list_find(x, "not_a_function"), error = TRUE)
})
