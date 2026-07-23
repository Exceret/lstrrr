# test-list_walk.R — tests for list_walk, list_walk2, list_pwalk, list_iwalk

# Shared test fixture ----------------------------------------------------------

x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  )
)

# list_walk -------------------------------------------------------------------

test_that("list_walk applies .f to every leaf", {
  out <- character()
  list_walk(x, function(val) out <<- c(out, as.character(val)))
  expect_setequal(out, c("1", "2", "3", "4"))
})

test_that("list_walk visits leaves in order", {
  out <- numeric()
  list_walk(x, function(val) out <<- c(out, val))
  expect_equal(out, c(1, 2, 3, 4))
})

test_that("list_walk returns x invisibly", {
  result <- withVisible(list_walk(x, identity))
  expect_false(result$visible)
  expect_identical(result$value, x)
})

test_that("list_walk supports formula .f", {
  out <- numeric()
  list_walk(
    x,
    ~ {
      out <<- c(out, .x)
    }
  )
  expect_setequal(out, c(1, 2, 3, 4))
})

test_that("list_walk forwards ... to .f", {
  out <- character()
  list_walk(
    x,
    function(val, prefix) out <<- c(out, paste0(prefix, val)),
    prefix = "v:"
  )
  expect_setequal(out, c("v:1", "v:2", "v:3", "v:4"))
})

test_that("list_walk treats data.frame as leaf", {
  lst <- list(a = iris[1:2, ], b = list(c = 1))
  out <- list()
  list_walk(lst, function(val) out <<- c(out, list(val)))
  expect_length(out, 2L)
  expect_identical(out[[1]], iris[1:2, ])
  expect_identical(out[[2]], 1)
})

test_that("list_walk on empty list does nothing", {
  out <- numeric()
  list_walk(list(), function(val) out <<- c(out, val))
  expect_length(out, 0L)
})

test_that("list_walk on NULL does nothing", {
  out <- numeric()
  list_walk(NULL, function(val) out <<- c(out, val))
  expect_length(out, 0L)
})

test_that("list_walk on atomic vector calls .f once", {
  out <- numeric()
  list_walk(1:5, function(val) out <<- c(out, val))
  expect_equal(out, 1:5)
})

test_that("list_walk handles NULL leaf values", {
  lst <- list(a = NULL, b = 1)
  out <- list()
  list_walk(lst, function(val) out <<- c(out, list(val)))
  expect_length(out, 2L)
  expect_null(out[[1]])
  expect_equal(out[[2]], 1)
})


test_that("list_walk errors on non-coercible .f", {
  expect_snapshot(list_walk(x, "not_a_function"), error = TRUE)
})

# list_walk2 ------------------------------------------------------------------

test_that("list_walk2 applies .f to corresponding leaves", {
  out <- numeric()
  list_walk2(x, x, function(a, b) out <<- c(out, a + b))
  expect_equal(out, c(2, 4, 6, 8))
})

test_that("list_walk2 returns x invisibly", {
  result <- withVisible(list_walk2(x, x, function(a, b) a + b))
  expect_false(result$visible)
  expect_identical(result$value, x)
})

test_that("list_walk2 supports formula .f", {
  out <- numeric()
  list_walk2(
    x,
    x,
    ~ {
      out <<- c(out, .x + .y)
    }
  )
  expect_equal(out, c(2, 4, 6, 8))
})

test_that("list_walk2 forwards ... to .f", {
  out <- numeric()
  list_walk2(
    x,
    x,
    function(a, b, mult) out <<- c(out, (a + b) * mult),
    mult = 10
  )
  expect_equal(out, c(20, 40, 60, 80))
})

test_that("list_walk2 handles mismatched lengths (shorter gets NULL)", {
  a <- list(1, 2)
  b <- list(10)
  out <- list()
  list_walk2(a, b, function(x, y) out <<- c(out, list(list(x = x, y = y))))
  expect_length(out, 2L)
  expect_equal(out[[1]], list(x = 1, y = 10))
  expect_equal(out[[2]], list(x = 2, y = NULL))
})

test_that("list_walk2 handles one side non-list as leaf", {
  a <- list(1, list(2, 3))
  b <- 99
  out <- list()
  list_walk2(a, b, function(x, y) out <<- c(out, list(list(x = x, y = y))))
  expect_length(out, 1L)
  expect_equal(out[[1]], list(x = a, y = 99))
})

test_that("list_walk2 treats data.frame as leaf", {
  a <- list(df = iris[1:2, ], num = 1)
  b <- list(df = iris[1:2, ], num = 2)
  out <- list()
  list_walk2(a, b, function(x, y) out <<- c(out, list(list(x = x, y = y))))
  expect_length(out, 2L)
  expect_identical(out[[1]]$x, iris[1:2, ])
  expect_identical(out[[1]]$y, iris[1:2, ])
})

test_that("list_walk2 on empty lists does nothing", {
  out <- numeric()
  list_walk2(list(), list(), function(a, b) out <<- c(out, a + b))
  expect_length(out, 0L)
})

test_that("list_walk2 on atomic vectors calls .f once each", {
  out <- numeric()
  list_walk2(1, 2, function(a, b) out <<- c(out, a + b))
  expect_equal(out, 3)
})

test_that("list_walk2 handles NULL leaf values", {
  a <- list(x = NULL, y = 1)
  b <- list(x = 2, y = NULL)
  out <- list()
  list_walk2(a, b, function(x, y) out <<- c(out, list(list(x = x, y = y))))
  expect_length(out, 2L)
  expect_null(out[[1]]$x)
  expect_equal(out[[1]]$y, 2)
  expect_null(out[[2]]$y)
  expect_equal(out[[2]]$x, 1)
})


test_that("list_walk2 errors on non-coercible .f", {
  expect_snapshot(list_walk2(x, x, "not_a_function"), error = TRUE)
})

# list_pwalk ------------------------------------------------------------------

test_that("list_pwalk applies .f to corresponding leaves of multiple lists", {
  out <- numeric()
  list_pwalk(list(x, x, x), function(a, b, c) out <<- c(out, a + b + c))
  expect_equal(out, c(3, 6, 9, 12))
})

test_that("list_pwalk returns .l invisibly", {
  lists <- list(x, x)
  result <- withVisible(list_pwalk(lists, function(a, b) a + b))
  expect_false(result$visible)
  expect_identical(result$value, lists)
})

test_that("list_pwalk supports formula .f", {
  out <- numeric()
  list_pwalk(
    list(x, x),
    ~ {
      out <<- c(out, .x + .y)
    }
  )
  expect_equal(out, c(2, 4, 6, 8))
})

test_that("list_pwalk forwards ... to .f", {
  out <- numeric()
  list_pwalk(
    list(x, x),
    function(a, b, mult) out <<- c(out, (a + b) * mult),
    mult = 10
  )
  expect_equal(out, c(20, 40, 60, 80))
})

test_that("list_pwalk handles mismatched lengths (shorter gets NULL)", {
  a <- list(1, 2, 3)
  b <- list(10, 20)
  out <- list()
  list_pwalk(list(a, b), function(x, y) {
    out <<- c(out, list(list(x = x, y = y)))
  })
  expect_length(out, 3L)
  expect_equal(out[[3]], list(x = 3, y = NULL))
})

test_that("list_pwalk treats data.frame as leaf", {
  a <- list(df = iris[1:2, ], num = 1)
  out <- list()
  list_pwalk(list(a, a), function(x, y) {
    out <<- c(out, list(list(x = x, y = y)))
  })
  expect_length(out, 2L)
  expect_identical(out[[1]]$x, iris[1:2, ])
})

test_that("list_pwalk with mixed list/non-list elements recurses where both are lists", {
  a <- list(1, list(2, 3))
  b <- list(10, list(20, 30))
  out <- list()
  list_pwalk(list(a, b), function(x, y) {
    out <<- c(out, list(list(x = x, y = y)))
  })
  # a[[1]]=1 (non-list), b[[1]]=10 (non-list) → .f(1, 10)
  # a[[2]]=list(2,3) (list), b[[2]]=list(20,30) (list) → recurse:
  #   2, 20 → .f(2, 20); 3, 30 → .f(3, 30)
  expect_length(out, 3L)
  expect_equal(out[[1]], list(x = 1, y = 10))
  expect_equal(out[[2]], list(x = 2, y = 20))
  expect_equal(out[[3]], list(x = 3, y = 30))
})

test_that("list_pwalk with all-list structure recurses fully", {
  a <- list(list(1, 2), list(3, 4))
  b <- list(list(5, 6), list(7, 8))
  out <- numeric()
  list_pwalk(list(a, b), function(x, y) out <<- c(out, x + y))
  expect_equal(out, c(6, 8, 10, 12))
})

test_that("list_pwalk with single list walks each leaf", {
  out <- numeric()
  list_pwalk(list(x), function(val) out <<- c(out, val))
  expect_setequal(out, c(1, 2, 3, 4))
})

test_that("list_pwalk handles NULL leaf values", {
  a <- list(x = NULL, y = 1)
  b <- list(x = 2, y = NULL)
  out <- list()
  list_pwalk(list(a, b), function(x, y) {
    out <<- c(out, list(list(x = x, y = y)))
  })
  expect_length(out, 2L)
  expect_null(out[[1]]$x)
  expect_equal(out[[1]]$y, 2)
  expect_null(out[[2]]$y)
  expect_equal(out[[2]]$x, 1)
})

test_that("list_pwalk errors on non-coercible .f", {
  expect_snapshot(list_pwalk(list(x), "not_a_function"), error = TRUE)
})

# list_iwalk ------------------------------------------------------------------

test_that("list_iwalk passes leaf name to .f", {
  out <- character()
  list_iwalk(x, function(value, name) out <<- c(out, paste(name, value, sep = "=")))
  expect_setequal(out, c("a=1", "x=2", "i=3", "j=4"))
})

test_that("list_iwalk returns x invisibly", {
  result <- withVisible(list_iwalk(x, function(value, name) value))
  expect_false(result$visible)
  expect_identical(result$value, x)
})

test_that("list_iwalk supports formula .f", {
  out <- character()
  list_iwalk(x, ~ {
    out <<- c(out, paste(.y, .x, sep = "="))
  })
  expect_setequal(out, c("a=1", "x=2", "i=3", "j=4"))
})

test_that("list_iwalk forwards ... to .f", {
  out <- character()
  list_iwalk(
    x,
    function(value, name, prefix) {
      out <<- c(out, paste0(prefix, name, ":", value))
    },
    prefix = "leaf_"
  )
  expect_setequal(out, c("leaf_a:1", "leaf_x:2", "leaf_i:3", "leaf_j:4"))
})

test_that("list_iwalk uses positional indices for unnamed elements", {
  lst <- list(10, 20, list(30, 40))
  out <- character()
  list_iwalk(lst, function(value, name) out <<- c(out, paste(name, value, sep = "=")))
  expect_setequal(out, c("1=10", "2=20", "1=30", "2=40"))
})

test_that("list_iwalk treats data.frame as leaf", {
  lst <- list(a = iris[1:2, ], b = list(c = 1))
  out <- character()
  list_iwalk(lst, function(value, name) out <<- c(out, name))
  expect_setequal(out, c("a", "c"))
})

test_that("list_iwalk on empty list does nothing", {
  out <- character()
  list_iwalk(list(), function(value, name) out <<- c(out, name))
  expect_length(out, 0L)
})

test_that("list_iwalk handles NULL leaf values", {
  lst <- list(a = NULL, b = 1)
  out <- character()
  list_iwalk(lst, function(value, name) out <<- c(out, name))
  expect_setequal(out, c("a", "b"))
})

test_that("list_iwalk errors on non-coercible .f", {
  expect_snapshot(list_iwalk(x, "not_a_function"), error = TRUE)
})

# .progress parameter ---------------------------------------------------------

test_that("list_walk works with .progress = FALSE", {
  out <- numeric()
  list_walk(x, function(val) out <<- c(out, val), .progress = FALSE)
  expect_equal(out, c(1, 2, 3, 4))
})

test_that("list_walk works with .progress = TRUE", {
  out <- numeric()
  list_walk(x, function(val) out <<- c(out, val), .progress = TRUE)
  expect_equal(out, c(1, 2, 3, 4))
})

test_that("list_walk works with named .progress", {
  out <- numeric()
  list_walk(x, function(val) out <<- c(out, val), .progress = "walking")
  expect_equal(out, c(1, 2, 3, 4))
})

test_that("list_walk2 works with .progress = FALSE", {
  out <- numeric()
  list_walk2(x, x, function(a, b) out <<- c(out, a + b), .progress = FALSE)
  expect_equal(out, c(2, 4, 6, 8))
})

test_that("list_walk2 works with .progress = TRUE", {
  out <- numeric()
  list_walk2(x, x, function(a, b) out <<- c(out, a + b), .progress = TRUE)
  expect_equal(out, c(2, 4, 6, 8))
})

test_that("list_pwalk works with .progress = FALSE", {
  out <- numeric()
  list_pwalk(list(x, x), function(a, b) out <<- c(out, a + b), .progress = FALSE)
  expect_equal(out, c(2, 4, 6, 8))
})

test_that("list_pwalk works with .progress = TRUE", {
  out <- numeric()
  list_pwalk(list(x, x), function(a, b) out <<- c(out, a + b), .progress = TRUE)
  expect_equal(out, c(2, 4, 6, 8))
})

test_that("list_iwalk works with .progress = FALSE", {
  out <- character()
  list_iwalk(x, function(value, name) out <<- c(out, name), .progress = FALSE)
  expect_setequal(out, c("a", "x", "i", "j"))
})

test_that("list_iwalk works with .progress = TRUE", {
  out <- character()
  list_iwalk(x, function(value, name) out <<- c(out, name), .progress = TRUE)
  expect_setequal(out, c("a", "x", "i", "j"))
})
