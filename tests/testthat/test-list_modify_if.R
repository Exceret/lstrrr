# test-list_modify_if.R — tests for list_modify_if

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

test_that("list_modify_if modifies leaves satisfying predicate", {
  result <- list_modify_if(
    x,
    .p = function(val) is.numeric(val) && val > 2,
    .f = function(val) val * 2
  )
  expect_identical(list_get(result, "a"), 1)         # unchanged (1 ≤ 2)
  expect_identical(list_get(result, c("b", "x")), 2)  # unchanged (2 ≤ 2)
  expect_identical(list_get(result, c("b", "y", "i")), 6)  # 3→6
  expect_identical(list_get(result, c("b", "y", "j")), 8)  # 4→8
  expect_identical(list_get(result, "c"), "text")     # unchanged (not numeric)
})

test_that("list_modify_if returns same structure when nothing matches", {
  result <- list_modify_if(x, .p = ~ FALSE, .f = ~ .x * 2)
  expect_identical(result, x)
})

test_that("list_modify_if modifies all leaves when predicate always TRUE", {
  result <- list_modify_if(
    list(a = 1, b = list(c = 2)),
    .p = ~ TRUE,
    .f = ~ .x + 10
  )
  expect_identical(result, list(a = 11, b = list(c = 12)))
})

test_that("list_modify_if returns a new list (does not mutate original)", {
  orig <- list(a = 1, b = 2)
  list_modify_if(orig, .p = ~ TRUE, .f = ~ .x + 1)
  expect_identical(orig, list(a = 1, b = 2))
})

test_that("list_modify_if preserves list names", {
  result <- list_modify_if(x, .p = ~ FALSE, .f = identity)
  expect_named(result, c("a", "b", "c"))
  expect_named(result[["b"]], c("x", "y"))
  expect_named(result[["b"]][["y"]], c("i", "j"))
})

# Formula support --------------------------------------------------------------

test_that("list_modify_if supports formula for .p and .f", {
  result <- list_modify_if(
    x,
    .p = ~ is.numeric(.x) && .x > 2,
    .f = ~ .x * 2
  )
  expect_identical(list_get(result, c("b", "y", "i")), 6)
  expect_identical(list_get(result, c("b", "y", "j")), 8)
})

test_that("list_modify_if supports function for .p and .f", {
  result <- list_modify_if(
    x,
    .p = is.numeric,
    .f = function(val) val + 1
  )
  expect_identical(list_get(result, "a"), 2)
  expect_identical(list_get(result, c("b", "x")), 3)
  expect_identical(list_get(result, c("b", "y", "i")), 4)
  expect_identical(list_get(result, c("b", "y", "j")), 5)
  expect_identical(list_get(result, "c"), "text")
})

# ... forwarding ---------------------------------------------------------------

test_that("list_modify_if forwards ... to .f", {
  result <- list_modify_if(
    x,
    .p = is.numeric,
    .f = function(val, inc) val + inc,
    inc = 100
  )
  expect_identical(list_get(result, "a"), 101)
  expect_identical(list_get(result, c("b", "y", "j")), 104)
})

# isTRUE behavior --------------------------------------------------------------

test_that("list_modify_if with NA predicate result does not modify", {
  result <- list_modify_if(x, .p = ~ NA, .f = ~ .x * 2)
  expect_identical(result, x)
})

test_that("list_modify_if with non-logical predicate result does not modify", {
  result <- list_modify_if(x, .p = ~ "not_logical", .f = ~ .x * 2)
  expect_identical(result, x)
})

test_that("list_modify_if with NULL predicate result does not modify", {
  result <- list_modify_if(x, .p = ~ NULL, .f = ~ .x * 2)
  expect_identical(result, x)
})

# Data frames ------------------------------------------------------------------

test_that("list_modify_if treats data.frame as leaf", {
  lst <- list(a = iris[1:2, ], b = list(c = 1))
  result <- list_modify_if(lst, .p = is.data.frame, .f = function(df) df[, 1:2])
  expect_identical(result[["a"]], iris[1:2, 1:2])
  expect_identical(result[["b"]][["c"]], 1)
})

test_that("list_modify_if does not recurse into data.frame", {
  lst <- list(a = iris[1:2, ])
  result <- list_modify_if(lst, .p = is.numeric, .f = ~ .x * 2)
  # The data.frame itself is the leaf, so .p(iris[1:2,]) → is.numeric returns FALSE
  # Leaves it unchanged
  expect_identical(result[["a"]], iris[1:2, ])
})

# Edge cases -------------------------------------------------------------------

test_that("list_modify_if on empty list returns empty list", {
  result <- list_modify_if(list(), .p = ~ TRUE, .f = ~ .x)
  expect_identical(result, list())
})

test_that("list_modify_if on NULL returns NULL", {
  result <- list_modify_if(NULL, .p = ~ TRUE, .f = ~ .x)
  expect_null(result)
})

test_that("list_modify_if on atomic vector treats it as single leaf", {
  result <- list_modify_if(1:5, .p = is.numeric, .f = ~ .x + 10)
  expect_equal(result, c(11, 12, 13, 14, 15))
})

test_that("list_modify_if handles NULL leaf values", {
  lst <- list(a = NULL, b = 1)
  result <- list_modify_if(lst, .p = is.null, .f = function(x) "was_null")
  expect_identical(result, list(a = "was_null", b = 1))
})

test_that("list_modify_if with deeply nested structure", {
  deep <- list(a = list(b = list(c = list(d = 1, e = 2))))
  result <- list_modify_if(deep, .p = ~ .x == 1, .f = ~ 999)
  expect_identical(list_get(result, c("a", "b", "c", "d")), 999)
  expect_identical(list_get(result, c("a", "b", "c", "e")), 2)
})

test_that("list_modify_if with multiple leaf types", {
  y <- list(
    int = 1L,
    dbl = 1.5,
    chr = "hello",
    lgl = TRUE
  )
  result <- list_modify_if(y, .p = is.character, .f = toupper)
  expect_identical(result[["int"]], 1L)
  expect_identical(result[["dbl"]], 1.5)
  expect_identical(result[["chr"]], "HELLO")
  expect_identical(result[["lgl"]], TRUE)
})

test_that("list_modify_if with unnamed list elements", {
  y <- list(1, list(2, 3))
  result <- list_modify_if(y, .p = ~ .x > 1, .f = ~ .x * 10)
  expect_identical(result, list(1, list(20, 30)))
})

# Error cases ------------------------------------------------------------------

test_that("list_modify_if errors on two-sided formula for .p", {
  expect_snapshot(
    list_modify_if(x, .p = y ~ x + 1, .f = identity),
    error = TRUE
  )
})

test_that("list_modify_if errors on two-sided formula for .f", {
  expect_snapshot(
    list_modify_if(x, .p = is.numeric, .f = y ~ x + 1),
    error = TRUE
  )
})

test_that("list_modify_if errors on non-coercible .p", {
  expect_snapshot(
    list_modify_if(x, .p = "not_a_function", .f = identity),
    error = TRUE
  )
})

test_that("list_modify_if errors on non-coercible .f", {
  expect_snapshot(
    list_modify_if(x, .p = is.numeric, .f = "not_a_function"),
    error = TRUE
  )
})

# Integration: verify recursive structure preservation -------------------------

test_that("list_modify_if preserves deep structure when partially modifying", {
  y <- list(
    keep = list(a = 1, b = 2),
    modify = list(c = 3, d = 4)
  )
  result <- list_modify_if(y, .p = ~ .x >= 3, .f = ~ .x * 10)
  expect_identical(result[["keep"]], list(a = 1, b = 2))
  expect_identical(result[["modify"]], list(c = 30, d = 40))
})

test_that("list_modify_if with only one leaf modified in deep tree", {
  deep <- list(a = list(b = 1, c = list(d = 2, e = 3)))
  result <- list_modify_if(deep, .p = ~ .x == 2, .f = ~ 999)
  expect_identical(list_get(result, c("a", "b")), 1)
  expect_identical(list_get(result, c("a", "c", "d")), 999)
  expect_identical(list_get(result, c("a", "c", "e")), 3)
})
