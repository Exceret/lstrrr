# test-list_filter.R — tests for list_filter

# Shared test fixture ----------------------------------------------------------

x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  ),
  c = "text"
)

# Core behavior ---------------------------------------------------------------

test_that("list_filter keeps matching leaves and drops others to NULL", {
  result <- list_filter(x, ~ is.numeric(.x) && .x > 2)
  expect_identical(result[["a"]], NULL) # 1 ≤ 2 → dropped
  expect_identical(result[["b"]][["x"]], NULL) # 2 ≤ 2 → dropped
  expect_identical(result[["b"]][["y"]][["i"]], 3)
  expect_identical(result[["b"]][["y"]][["j"]], 4)
  expect_identical(result[["c"]], NULL) # not numeric → dropped
})

test_that("list_filter preserves structure and names", {
  result <- list_filter(x, is.numeric)
  expect_named(result, c("a", "b", "c"))
  expect_named(result[["b"]], c("x", "y"))
  expect_named(result[["b"]][["y"]], c("i", "j"))
})

test_that("list_filter supports function predicate", {
  result <- list_filter(x, function(val) val == 2)
  expect_identical(result[["b"]][["x"]], 2)
  expect_identical(result[["a"]], NULL)
  expect_identical(result[["c"]], NULL)
})

test_that("list_filter keeps everything when predicate always TRUE", {
  result <- list_filter(x, ~TRUE)
  expect_identical(result, x)
})

test_that("list_filter drops everything when predicate always FALSE", {
  result <- list_filter(x, ~FALSE)
  expect_identical(
    result,
    list(a = NULL, b = list(x = NULL, y = list(i = NULL, j = NULL)), c = NULL)
  )
})

test_that("list_filter returns a new list (does not mutate original)", {
  orig <- list(a = 1, b = 2)
  list_filter(orig, ~FALSE)
  expect_identical(orig, list(a = 1, b = 2))
})

# isTRUE behavior --------------------------------------------------------------

test_that("list_filter with NA predicate result drops leaf", {
  result <- list_filter(x, ~NA)
  expect_identical(
    result,
    list(a = NULL, b = list(x = NULL, y = list(i = NULL, j = NULL)), c = NULL)
  )
})

test_that("list_filter with non-logical predicate result drops leaf", {
  result <- list_filter(x, ~"not_logical")
  expect_identical(
    result,
    list(a = NULL, b = list(x = NULL, y = list(i = NULL, j = NULL)), c = NULL)
  )
})

test_that("list_filter with NULL predicate result drops leaf", {
  result <- list_filter(x, ~NULL)
  expect_identical(
    result,
    list(a = NULL, b = list(x = NULL, y = list(i = NULL, j = NULL)), c = NULL)
  )
})

# Edge cases -------------------------------------------------------------------

test_that("list_filter on empty list returns empty list", {
  result <- list_filter(list(), ~TRUE)
  expect_identical(result, list())
})

test_that("list_filter on NULL returns NULL", {
  expect_null(list_filter(NULL, ~TRUE))
})

test_that("list_filter on atomic vector treats it as single leaf", {
  expect_identical(list_filter(1:5, is.numeric), 1:5)
  expect_null(list_filter(1:5, ~FALSE))
})

test_that("list_filter treats data.frame as leaf", {
  lst <- list(a = iris[1:2, ], b = list(c = 1))
  result <- list_filter(lst, is.data.frame)
  expect_identical(result[["a"]], iris[1:2, ])
  expect_identical(result[["b"]][["c"]], NULL)
})

test_that("list_filter does not recurse into data.frame", {
  lst <- list(a = iris[1:2, ])
  result <- list_filter(lst, is.numeric)
  expect_identical(result, list(a = NULL))
})

test_that("list_filter with deeply nested structure", {
  deep <- list(a = list(b = list(c = list(d = 1, e = 2))))
  result <- list_filter(deep, ~ .x == 1)
  expect_identical(result, list(a = list(b = list(c = list(d = 1, e = NULL)))))
})

test_that("list_filter with unnamed list elements", {
  y <- list(1, list(2, 3))
  result <- list_filter(y, ~ .x > 1)
  expect_identical(result, list(NULL, list(2, 3)))
})

test_that("list_filter handles NULL leaf values without error", {
  y <- list(a = NULL, b = 2)
  result <- list_filter(y, is.numeric)
  expect_named(result, c("a", "b"))
  expect_identical(result[["b"]], 2)
})

test_that("list_filter with multiple leaf types", {
  y <- list(
    int = 1L,
    dbl = 1.5,
    chr = "hello",
    lgl = TRUE
  )
  result <- list_filter(y, is.character)
  expect_identical(result[["int"]], NULL)
  expect_identical(result[["dbl"]], NULL)
  expect_identical(result[["chr"]], "hello")
  expect_identical(result[["lgl"]], NULL)
})

# Error cases ------------------------------------------------------------------

test_that("list_filter errors on two-sided formula for .p", {
  expect_snapshot(list_filter(x, y ~ x + 1), error = TRUE)
})

test_that("list_filter errors on non-coercible .p", {
  expect_snapshot(list_filter(x, "not_a_function"), error = TRUE)
})
