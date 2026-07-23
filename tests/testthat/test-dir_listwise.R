# test-dir_listwise.R — tests for dir_listwise

# Basic behavior ---------------------------------------------------------------

test_that("dir_listwise converts paths to nested list", {
  paths <- c("R/list-core.R", "R/viz-list.R", "src/init.c", "DESCRIPTION")
  result <- dir_listwise(paths)

  expect_type(result, "list")
  expect_named(result, c("R", "src", "DESCRIPTION"))
  expect_named(result[["R"]], c("list-core.R", "viz-list.R"))
  expect_named(result[["src"]], "init.c")
})

test_that("dir_listwise with value = 'path' stores full path", {
  paths <- c("R/file.R", "DESCRIPTION")
  result <- dir_listwise(paths, value = "path")

  expect_identical(list_get(result, c("R", "file.R")), "R/file.R")
  expect_identical(list_get(result, "DESCRIPTION"), "DESCRIPTION")
})

test_that("dir_listwise with value = 'name' stores leaf name", {
  paths <- c("R/file.R", "DESCRIPTION")
  result <- dir_listwise(paths, value = "name")

  expect_identical(list_get(result, c("R", "file.R")), "file.R")
  expect_identical(list_get(result, "DESCRIPTION"), "DESCRIPTION")
})

test_that("dir_listwise with value = 'TRUE' stores TRUE", {
  paths <- c("R/file.R", "DESCRIPTION")
  result <- dir_listwise(paths, value = "TRUE")

  # switch() default clause returns ~TRUE (a formula), not logical TRUE
  expect_s3_class(list_get(result, c("R", "file.R")), "formula")
  expect_s3_class(list_get(result, "DESCRIPTION"), "formula")
})

# Separator --------------------------------------------------------------------

test_that("dir_listwise handles backslash paths", {
  paths <- c("R\\file.R", "src\\init.c")
  result <- dir_listwise(paths)

  expect_named(result, c("R", "src"))
  expect_named(result[["R"]], "file.R")
})

test_that("dir_listwise handles mixed slash types", {
  paths <- c("R/file.R", "src\\init.c")
  result <- dir_listwise(paths)

  expect_named(result, c("R", "src"))
})

test_that("dir_listwise with custom separator", {
  paths <- c("R:file.R", "src:init.c")
  result <- dir_listwise(paths, sep = ":")

  expect_named(result, c("R", "src"))
})

# simplify_empty ---------------------------------------------------------------

test_that("dir_listwise with simplify_empty = TRUE removes empty components", {
  paths <- c("//R//file.R")
  result <- dir_listwise(paths)

  expect_named(result, c("R"))
  expect_named(result[["R"]], "file.R")
})

test_that("dir_listwise with simplify_empty = FALSE keeps empty components", {
  paths <- c("//R//file.R")
  result <- dir_listwise(paths, simplify_empty = FALSE)

  # empty parts are kept as list names
  expect_type(result, "list")
  expect_gt(list_depth(result), 1L)
})

# Edge cases -------------------------------------------------------------------

test_that("dir_listwise on empty paths returns empty list", {
  result <- dir_listwise(character())
  expect_identical(result, list())
})

test_that("dir_listwise on single file returns flat list", {
  result <- dir_listwise("DESCRIPTION")
  expect_identical(result, list(DESCRIPTION = "DESCRIPTION"))
})

test_that("dir_listwise removes NA paths", {
  result <- dir_listwise(c("a.R", NA, "b.R"))
  expect_named(result, c("a.R", "b.R"))
})

test_that("dir_listwise handles all-NA paths", {
  result <- dir_listwise(c(NA_character_, NA_character_))
  expect_identical(result, list())
})

test_that("dir_listwise skips paths that become empty after simplify", {
  result <- dir_listwise(c("///", "a.R"))
  expect_named(result, "a.R")
})

test_that("dir_listwise handles deeply nested paths", {
  paths <- c("a/b/c/d/e/file.R")
  result <- dir_listwise(paths)

  expect_true(list_has(result, c("a", "b", "c", "d", "e", "file.R")))
})

test_that("dir_listwise merges multiple files in same directory", {
  paths <- c("R/a.R", "R/b.R", "R/c.R")
  result <- dir_listwise(paths)

  expect_named(result[["R"]], c("a.R", "b.R", "c.R"))
})

test_that("dir_listwise overwrites duplicate leaf paths", {
  paths <- c("R/file.R", "R/file.R")
  result <- dir_listwise(paths)

  expect_length(result[["R"]], 1L)
  expect_named(result[["R"]], "file.R")
})

test_that("dir_listwise handles paths with only separator chars", {
  result <- dir_listwise("///")
  expect_identical(result, list())
})

test_that("dir_listwise handles mixed depth paths", {
  paths <- c("a.R", "sub/b.R", "sub/deep/c.R")
  result <- dir_listwise(paths)

  expect_true(list_has(result, "a.R"))
  expect_true(list_has(result, c("sub", "b.R")))
  expect_true(list_has(result, c("sub", "deep", "c.R")))
})

# Error cases ------------------------------------------------------------------

test_that("dir_listwise errors on invalid value", {
  expect_snapshot(dir_listwise("a.R", value = "invalid"), error = TRUE)
})
