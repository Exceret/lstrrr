test_that("keep.null must be TRUE or FALSE (length-1 logical)", {
  expect_snapshot(
    modify_list(list(a = 1), list(b = 2), keep.null = "yes"),
    error = TRUE
  )
  expect_snapshot(
    modify_list(list(a = 1), list(b = 2), keep.null = c(TRUE, FALSE)),
    error = TRUE
  )
})

test_that("keep.null must not be NA", {
  expect_snapshot(
    modify_list(list(a = 1), list(b = 2), keep.null = NA),
    error = TRUE
  )
})

test_that("x must be a list (not a data.frame)", {
  expect_snapshot(
    modify_list(data.frame(a = 1), list(b = 2)),
    error = TRUE
  )
})

test_that("x must be a list (not an atomic vector)", {
  expect_snapshot(
    modify_list(c(a = 1), list(b = 2)),
    error = TRUE
  )
})

test_that("val must be a list", {
  expect_snapshot(
    modify_list(list(a = 1), c(b = 2)),
    error = TRUE
  )
  expect_snapshot(
    modify_list(list(a = 1), data.frame(b = 2)),
    error = TRUE
  )
})

test_that("val must be a named list", {
  expect_snapshot(
    modify_list(list(a = 1), list(1, 2)),
    error = TRUE
  )
})

test_that("val must not have invalid names", {
  expect_snapshot(
    modify_list(list(a = 1), stats::setNames(list(1, 2), c("a", NA))),
    error = TRUE
  )
  expect_snapshot(
    modify_list(list(a = 1), stats::setNames(list(1, 2), c("a", ""))),
    error = TRUE
  )
})

test_that("val elements overwrite x at the same key", {
  result <- modify_list(list(a = 1, b = 2), list(b = 99))
  expect_identical(result, list(a = 1, b = 99))
})

test_that("val elements are appended to x for new keys", {
  result <- modify_list(list(a = 1), list(b = 2, c = 3))
  expect_identical(result, list(a = 1, b = 2, c = 3))
})

test_that("NULL in val removes key from x when keep.null = FALSE (default)", {
  result <- modify_list(list(a = 1, b = 2), list(b = NULL))
  expect_identical(result, list(a = 1))
})

test_that("NULL in val for non-existent key is a no-op when keep.null = FALSE", {
  result <- modify_list(list(a = 1), list(z = NULL))
  expect_identical(result, list(a = 1))
})

test_that("NULL in val is kept when keep.null = TRUE", {
  result <- modify_list(list(a = 1), list(b = NULL), keep.null = TRUE)
  expect_identical(result, list(a = 1, b = NULL))
})

test_that("recursive merge when both x and val elements are lists", {
  x <- list(a = list(x = 1, y = 2))
  val <- list(a = list(y = 99, z = 3))
  result <- modify_list(x, val)
  expect_identical(result, list(a = list(x = 1, y = 99, z = 3)))
})

test_that("val list overwrites x scalar at same key (non-recursive)", {
  x <- list(a = 1)
  val <- list(a = list(b = 2))
  result <- modify_list(x, val)
  expect_identical(result, list(a = list(b = 2)))
})

test_that("val scalar overwrites x list at same key (non-recursive)", {
  x <- list(a = list(x = 1, y = 2))
  val <- list(a = 99)
  result <- modify_list(x, val)
  expect_identical(result, list(a = 99))
})

test_that("deeply nested recursive merge", {
  x <- list(
    a = 1,
    b = list(
      x = 1,
      y = list(i = 1, j = 2)
    )
  )
  val <- list(
    b = list(
      y = list(j = 99, k = 100)
    ),
    c = 3
  )
  result <- modify_list(x, val)
  expect_identical(
    result,
    list(
      a = 1,
      b = list(
        x = 1,
        y = list(i = 1, j = 99, k = 100)
      ),
      c = 3
    )
  )
})

test_that("empty x with val appends all val elements", {
  result <- modify_list(list(), list(a = 1, b = 2))
  expect_identical(result, list(a = 1, b = 2))
})

test_that("empty val is an error (must be named)", {
  expect_snapshot(
    modify_list(list(a = 1), list()),
    error = TRUE
  )
})

test_that("NULL removal propagates recursively when keep.null = FALSE", {
  x <- list(a = list(x = 1, y = 2))
  val <- list(a = list(y = NULL))
  result <- modify_list(x, val)
  expect_identical(result, list(a = list(x = 1)))
})

test_that("recursive keep.null = TRUE preserves NULL at all levels", {
  x <- list(a = list(x = 1, y = 2))
  val <- list(a = list(y = NULL, z = NULL))
  result <- modify_list(x, val, keep.null = TRUE)
  expect_identical(result, list(a = list(x = 1, y = NULL, z = NULL)))
})

test_that("data.frame inside x is treated as non-list (not recursed into)", {
  x <- list(a = iris[1:3, ])
  val <- list(a = list(b = 2))
  result <- modify_list(x, val)
  expect_identical(result, list(a = list(b = 2)))
})

test_that("data.frame inside val overwrites x element (not recursed into)", {
  x <- list(a = list(x = 1))
  val <- list(a = iris[1:3, ])
  result <- modify_list(x, val)
  expect_identical(result, list(a = iris[1:3, ]))
})

test_that("multiple keys modified in a single call", {
  x <- list(a = 1, b = 2, c = 3, d = 4)
  val <- list(a = 10, c = 30, e = 50)
  result <- modify_list(x, val)
  expect_identical(result, list(a = 10, b = 2, c = 30, d = 4, e = 50))
})

test_that("return value is identical to expected merge result", {
  result <- modify_list(list(a = 1), list(b = 2))
  expect_identical(result, list(a = 1, b = 2))
})

test_that("NULL removal with keep.null = FALSE does not affect other keys", {
  x <- list(a = 1, b = 2, c = 3)
  val <- list(b = NULL)
  result <- modify_list(x, val)
  expect_identical(result, list(a = 1, c = 3))
})

test_that("unnamed x works correctly", {
  x <- list(1, 2, 3)
  val <- list(a = 99)
  result <- modify_list(x, val)
  expect_identical(result, list(1, 2, 3, a = 99))
})

test_that("partially named x works correctly", {
  x <- list(a = 1, 2, c = 3)
  val <- list(a = 99, b = 100)
  result <- modify_list(x, val)
  expect_identical(result, list(a = 99, 2, c = 3, b = 100))
})
