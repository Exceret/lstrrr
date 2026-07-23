# Set a nested element by path

Set a nested element by path

## Usage

``` r
list_set(x, path, value)
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

- value:

  Value to set at `path`.

  This value replaces the existing element located at `path`. It may be
  any R object.

## Value

A modified copy of `x` with `value` assigned at `path`.

## See also

[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_has()`](https://exceret.github.io/lstrrr/reference/list_has.md)

Other lstrrr_core:
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md),
[`list_depth()`](https://exceret.github.io/lstrrr/reference/list_depth.md),
[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_has()`](https://exceret.github.io/lstrrr/reference/list_has.md),
[`list_nleaf()`](https://exceret.github.io/lstrrr/reference/list_nleaf.md),
[`list_path()`](https://exceret.github.io/lstrrr/reference/list_path.md)

## Examples

``` r
x <- list(
  a = 1,
  b = list(
    x = 1,
    y = list(i = 1, j = 2)
  )
)

list_set(x, c("b", "x"), 2)
#> $a
#> [1] 1
#> 
#> $b
#> $b$x
#> [1] 2
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

# Set a deeply nested value
list_set(x, c("b", "y", "i"), 100)
#> $a
#> [1] 1
#> 
#> $b
#> $b$x
#> [1] 1
#> 
#> $b$y
#> $b$y$i
#> [1] 100
#> 
#> $b$y$j
#> [1] 2
#> 
#> 
#> 

# Integer paths use positional indices
list_set(x, c(2L, 2L, 2L), 200)
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [[2]][[1]]
#> [1] 1
#> 
#> [[2]][[2]]
#> [[2]][[2]][[1]]
#> [1] 1
#> 
#> [[2]][[2]][[2]]
#> [1] 200
#> 
#> 
#> 

# Empty path replaces the whole object
list_set(x, character(0), "replacement")
#> [1] "replacement"

# The original object is unchanged unless reassigned
x2 <- list_set(x, c("b", "x"), 2)
x$b$x
#> [1] 1
x2$b$x
#> [1] 2
```
