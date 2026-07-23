# Modify a List with Another List

A faster version of
[`utils::modifyList()`](https://rdrr.io/r/utils/modifyList.html).

## Usage

``` r
modify_list(x, val, keep.null = FALSE)
```

## Arguments

- x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

- val:

  A named list whose components modify `x`.

- keep.null:

  Logical. If `TRUE`, `NULL` values in `val` are kept. If `FALSE`,
  `NULL` values remove corresponding components from `x`.

## Value

A modified list.

## Examples

``` r
# \donttest{
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

modify_list(x, val)
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
#> [1] 99
#> 
#> $b$y$k
#> [1] 100
#> 
#> 
#> 
#> $c
#> [1] 3
#> 
# }
```
