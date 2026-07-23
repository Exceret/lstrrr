# Check whether a path exists in a nested list

Check whether a path exists in a nested list

## Usage

``` r
list_has(x, path)
```

## Arguments

- x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

- path:

  Character or integer vector giving the path to retrieve.

  For a character path, each component selects a named element at the
  current level. For an integer path, each component selects an element
  by position. Positional indices are one-based, following normal R
  indexing conventions.

  The path is evaluated from left to right. For example,
  `c("b", "y", "i")` means `x[["b"]][["y"]][["i"]]`.

## Value

A logical scalar:

- `TRUE` if `path` exists in `x`;

- `FALSE` otherwise.

## See also

Other lstrrr_core:
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md),
[`list_depth()`](https://exceret.github.io/lstrrr/reference/list_depth.md),
[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_nleaf()`](https://exceret.github.io/lstrrr/reference/list_nleaf.md),
[`list_path()`](https://exceret.github.io/lstrrr/reference/list_path.md),
[`list_set()`](https://exceret.github.io/lstrrr/reference/list_set.md)

## Examples

``` r
x <- list(
  a = 1,
  b = list(
    x = 1,
    y = list(i = 1, j = 2)
  ),
  unnamed = list(10, 20),
  df = data.frame(z = 1:3)
)

list_has(x, c("b", "x"))
#> [1] TRUE
list_has(x, c("b", "y", "i"))
#> [1] TRUE
list_has(x, c("b", "y", "k"))
#> [1] FALSE

# Integer paths use positional indices
list_has(x, c(2L, 2L, 1L))
#> [1] TRUE

# Empty path refers to `x` itself, always returns TRUE
list_has(x, character(0))
#> [1] TRUE

# Data frames are treated as leaves
list_has(x, "df")
#> [1] TRUE
list_has(x, c("df", "z")) # FALSE
#> [1] FALSE
```
