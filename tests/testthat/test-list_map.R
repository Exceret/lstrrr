# test-list_map.R — tests for list_map, list_map2, list_pmap, list_imap

# Shared test fixture ----------------------------------------------------------

x <- list(
  a = 1,
  b = list(
    x = 1,
    y = list(i = 1, j = 2)
  )
)

# list_map --------------------------------------------------------------------

test_that("list_map applies .f to every leaf", {
  out <- list_map(x, function(v) v + 1)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 3))))
})

test_that("list_map preserves structure and names", {
  out <- list_map(x, function(v) v)
  expect_identical(out, x)
})

test_that("list_map supports formula .f", {
  out <- list_map(x, ~ .x + 1)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 3))))
})

test_that("list_map passes ... to .f", {
  out <- list_map(x, function(v, k) v + k, k = 10)
  expect_identical(
    out,
    list(a = 11, b = list(x = 11, y = list(i = 11, j = 12)))
  )
})

test_that("list_map treats data.frame as leaf", {
  df <- data.frame(x = 1:3)
  lst <- list(a = df, b = list(c = 1))
  out <- list_map(lst, function(v) if (is.data.frame(v)) nrow(v) else v)
  expect_identical(out, list(a = 3L, b = list(c = 1)))
})

test_that("list_map handles empty list", {
  out <- list_map(list(), identity)
  expect_identical(out, list())
  expect_null(names(out))
})

test_that("list_map handles unnamed elements", {
  lst <- list(1, 2, list(3, 4))
  out <- list_map(lst, function(v) v * 10)
  expect_identical(out, list(10, 20, list(30, 40)))
})

test_that("list_map handles single leaf (non-list input)", {
  out <- list_map(5, function(v) v * 2)
  expect_identical(out, 10)
})

test_that("list_map handles NULL leaves", {
  lst <- list(a = NULL, b = list(c = NULL))
  out <- list_map(lst, function(v) if (is.null(v)) "null" else v)
  expect_identical(out, list(a = "null", b = list(c = "null")))
})

test_that("list_map works with .progress = FALSE", {
  out <- list_map(x, function(v) v, .progress = FALSE)
  expect_identical(out, x)
})

test_that("list_map works with .progress = TRUE", {
  out <- list_map(x, function(v) v, .progress = TRUE)
  expect_identical(out, x)
})

test_that("list_map works with named .progress", {
  out <- list_map(x, function(v) v, .progress = "mapping")
  expect_identical(out, x)
})

# list_map2 -------------------------------------------------------------------

test_that("list_map2 applies .f pairwise to leaves of both lists", {
  out <- list_map2(x, x, function(a, b) a + b)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

test_that("list_map2 supports formula .f", {
  out <- list_map2(x, x, ~ .x + .y)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

test_that("list_map2 passes ... to .f", {
  out <- list_map2(x, x, function(a, b, k) a + b + k, k = 10)
  expect_identical(
    out,
    list(a = 12, b = list(x = 12, y = list(i = 12, j = 14)))
  )
})

test_that("list_map2 handles different-length lists", {
  a <- list(x = 1, y = list(z = 2))
  b <- list(x = 10)
  out <- list_map2(a, b, function(v1, v2) {
    if (is.null(v1)) return("v1-missing")
    if (is.null(v2)) return("v2-missing")
    v1 + v2
  })
  expect_identical(out, list(x = 11, y = "v2-missing"))
})

test_that("list_map2 handles both leaves as non-lists", {
  out <- list_map2(3, 5, function(a, b) a + b)
  expect_identical(out, 8)
})

test_that("list_map2 treats data.frame as leaf", {
  df1 <- data.frame(x = 1:3)
  df2 <- data.frame(x = 4:6)
  lst <- list(a = df1, b = list(c = 1))
  out <- list_map2(lst, lst, function(v1, v2) {
    if (is.data.frame(v1)) nrow(v1) + nrow(v2) else v1 + v2
  })
  expect_identical(out, list(a = 6L, b = list(c = 2)))
})

test_that("list_map2 works with .progress = FALSE", {
  out <- list_map2(x, x, function(a, b) a + b, .progress = FALSE)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

test_that("list_map2 works with .progress = TRUE", {
  out <- list_map2(x, x, function(a, b) a + b, .progress = TRUE)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

test_that("list_map2 uses names from .x when both have names", {
  out <- list_map2(
    list(x = 1, y = 2),
    list(a = 10, b = 20),
    function(a, b) a + b
  )
  expect_named(out, c("x", "y"))
})

# list_pmap -------------------------------------------------------------------

test_that("list_pmap applies .f positionally to leaves", {
  out <- list_pmap(list(x, x), function(a, b) a + b)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

test_that("list_pmap works with three lists", {
  out <- list_pmap(list(x, x, x), function(a, b, c) a + b + c)
  expect_identical(out, list(a = 3, b = list(x = 3, y = list(i = 3, j = 6))))
})

test_that("list_pmap supports formula .f", {
  out <- list_pmap(list(x, x), ~ .x + .y)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

test_that("list_pmap passes ... to .f", {
  out <- list_pmap(list(x, x), function(a, b, k) a + b + k, k = 10)
  expect_identical(
    out,
    list(a = 12, b = list(x = 12, y = list(i = 12, j = 14)))
  )
})

test_that("list_pmap errors on non-list .l", {
  expect_error(
    list_pmap("not a list", identity)
  )
})

test_that("list_pmap errors on empty .l", {
  expect_error(
    list_pmap(list(), identity)
  )
})

test_that("list_pmap handles different-length sub-lists", {
  a <- list(x = 1, y = list(z = 2))
  b <- list(x = 10)
  out <- list_pmap(list(a, b), function(v1, v2) {
    if (is.null(v1)) return("v1-missing")
    if (is.null(v2)) return("v2-missing")
    v1 + v2
  })
  expect_identical(out, list(x = 11, y = "v2-missing"))
})

test_that("list_pmap treats data.frame as leaf", {
  df <- data.frame(x = 1:3)
  lst <- list(a = df, b = list(c = 1))
  out <- list_pmap(list(lst, lst), function(v1, v2) {
    if (is.data.frame(v1)) nrow(v1) + nrow(v2) else v1 + v2
  })
  expect_identical(out, list(a = 6L, b = list(c = 2)))
})

test_that("list_pmap works with single-list .l", {
  out <- list_pmap(list(x), function(v) v * 2)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

test_that("list_pmap works with .progress = FALSE", {
  out <- list_pmap(list(x, x), function(a, b) a + b, .progress = FALSE)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

test_that("list_pmap works with .progress = TRUE", {
  out <- list_pmap(list(x, x), function(a, b) a + b, .progress = TRUE)
  expect_identical(out, list(a = 2, b = list(x = 2, y = list(i = 2, j = 4))))
})

# list_imap -------------------------------------------------------------------

test_that("list_imap passes leaf name to .f (default .name = 'name')", {
  out <- list_imap(x, function(value, name) paste(name, value, sep = "="))
  expect_identical(
    out,
    list(a = "a=1", b = list(x = "x=1", y = list(i = "i=1", j = "j=2")))
  )
})

test_that("list_imap with .name = 'path' passes full path", {
  out <- list_imap(
    x,
    function(value, path) paste(paste(path, collapse = "."), value, sep = "="),
    .name = "path"
  )
  expect_identical(
    out,
    list(
      a = "a=1",
      b = list(x = "b.x=1", y = list(i = "b.y.i=1", j = "b.y.j=2"))
    )
  )
})

test_that("list_imap passes ... to .f", {
  out <- list_imap(
    x,
    function(value, name, prefix) paste0(prefix, name, ":", value),
    prefix = "leaf_"
  )
  expect_identical(
    out,
    list(
      a = "leaf_a:1",
      b = list(
        x = "leaf_x:1",
        y = list(i = "leaf_i:1", j = "leaf_j:2")
      )
    )
  )
})

test_that("list_imap uses positional indices for unnamed elements", {
  lst <- list(10, 20, list(30, 40))
  out <- list_imap(lst, function(value, name) paste(name, value, sep = "="))
  expect_identical(out, list("1=10", "2=20", list("1=30", "2=40")))
})

test_that("list_imap with .name = 'path' uses positional indices for unnamed", {
  lst <- list(a = 1, list(b = 2))
  out <- list_imap(
    lst,
    function(value, path) paste(paste(path, collapse = "."), value, sep = "="),
    .name = "path"
  )
  expect_identical(out, list(a = "a=1", list(b = "2.b=2")))
})

test_that("list_imap supports formula .f", {
  out <- list_imap(x, ~ paste(.y, .x, sep = "="))
  expect_identical(
    out,
    list(a = "a=1", b = list(x = "x=1", y = list(i = "i=1", j = "j=2")))
  )
})

test_that("list_imap treats data.frame as leaf", {
  df <- data.frame(x = 1:3)
  lst <- list(a = df, b = list(c = 1))
  out <- list_imap(lst, function(value, name) name)
  expect_identical(out, list(a = "a", b = list(c = "c")))
})

test_that("list_imap works with .progress = FALSE", {
  out <- list_imap(x, function(value, name) value, .progress = FALSE)
  expect_identical(out, x)
})

test_that("list_imap works with .progress = TRUE", {
  out <- list_imap(x, function(value, name) value, .progress = TRUE)
  expect_identical(out, x)
})

test_that("list_imap works with named .progress", {
  out <- list_imap(x, function(value, name) value, .progress = "imapping")
  expect_identical(out, x)
})

test_that("list_imap errors on invalid .name", {
  expect_error(
    list_imap(x, identity, .name = "invalid"),
    class = "rlang_error"
  )
})

test_that("list_imap .name = 'path' works with deeply nested lists", {
  deep <- list(a = list(b = list(c = 1)))
  out <- list_imap(
    deep,
    function(value, path) paste(path, collapse = "."),
    .name = "path"
  )
  expect_identical(out, list(a = list(b = list(c = "a.b.c"))))
})
