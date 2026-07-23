# Find leaves satisfying predicate

Find leaves satisfying predicate

## Usage

``` r
list_find(.x, .p)
```

## Arguments

- .x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

- .p:

  A predicate function, formula, or function-like object coercible by
  [`rlang::as_function()`](https://rlang.r-lib.org/reference/as_function.html).

## Value

A flat list containing the leaf values of `x` for which `.p` returns
`TRUE`.

The names of the returned list correspond to the flattened paths of the
matching leaves.

## See also

[`list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md)

## Examples

``` r
x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  ),
  unnamed = list(5, z = 6)
)
list_find(x, ~ .x > 2 & .x < 5)
#> $b.y.i
#> [1] 3
#> 
#> $b.y.j
#> [1] 4
#> 
# $b.y.i
# [1] 3
#
# $b.y.j
# [1] 4

# Use a regular function
list_find(x, function(value) value %% 2 == 0)
#> $b.x
#> [1] 2
#> 
#> $b.y.j
#> [1] 4
#> 
#> $unnamed.z
#> [1] 6
#> 

# Non-TRUE predicate results are not kept
list_find(x, ~ NA)
#> named list()
```
