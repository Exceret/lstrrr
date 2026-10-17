# Get an element from a nested list by path

Get an element from a nested list by path

## Usage

``` r
list_get(x, path, default = NULL)
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

- default:

  Value returned when the requested path does not exist or cannot be
  traversed.

  The default is `NULL`.

## Value

The value stored at `path`, or `default` if the path is missing or
invalid.

## See also

Other lstrrr_core:
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md),
[`list_depth()`](https://exceret.github.io/lstrrr/reference/list_depth.md),
[`list_find_value()`](https://exceret.github.io/lstrrr/reference/list_find_value.md),
[`list_has()`](https://exceret.github.io/lstrrr/reference/list_has.md),
[`list_nleaf()`](https://exceret.github.io/lstrrr/reference/list_nleaf.md),
[`list_path()`](https://exceret.github.io/lstrrr/reference/list_path.md),
[`list_rename()`](https://exceret.github.io/lstrrr/reference/list_rename.md),
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

list_get(x, c("b", "x"))
#> [1] 1
list_get(x, c("b", "y", "i"))
#> [1] 1

# Integer paths use positional indices
list_get(x, c(2L, 2L, 2L))
#> [1] 2

# Missing paths return `default`
list_get(x, c("b", "missing"), default = NA)
#> [1] NA

# Empty path returns the original object
list_get(x, character(0))
#> $a
#> [1] 1
#> 
#> $b
#> $b$x
#> [1] 1
#> 
#> $b$y
#> $b$y$i
#> [1] 1
#> 
#> $b$y$j
#> [1] 2
#> 
#> 
#> 
#> $unnamed
#> $unnamed[[1]]
#> [1] 10
#> 
#> $unnamed[[2]]
#> [1] 20
#> 
#> 
#> $df
#>   z
#> 1 1
#> 2 2
#> 3 3
#> 

# Data frames are treated as leaves
list_get(x, "df")
#>   z
#> 1 1
#> 2 2
#> 3 3
list_get(x, c("df", "z"), default = "not traversed")
#> [1] "not traversed"

```
