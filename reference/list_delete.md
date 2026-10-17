# Delete a nested element by path

Delete a nested element by path

## Usage

``` r
list_delete(x, path)
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

A modified copy of `x` with the element at `path` removed.

## See also

[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_has()`](https://exceret.github.io/lstrrr/reference/list_has.md),
[`list_set()`](https://exceret.github.io/lstrrr/reference/list_set.md)

Other lstrrr_core:
[`list_depth()`](https://exceret.github.io/lstrrr/reference/list_depth.md),
[`list_find_value()`](https://exceret.github.io/lstrrr/reference/list_find_value.md),
[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
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
  )
)

list_delete(x, c("b", "y", "j"))
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
#> 
#> 

# Delete by integer path
list_delete(x, c(2L, 2L, 1L))
#> $a
#> [1] 1
#> 
#> $b
#> $b$x
#> [1] 1
#> 
#> $b$y
#> $b$y$j
#> [1] 2
#> 
#> 
#> 

# The original object is unchanged unless reassigned
x2 <- list_delete(x, c("b", "x"))
names(x$b)
#> [1] "x" "y"
names(x2$b)
#> [1] "y"
```
