# Count Leaf Nodes in a Nested List

Count the number of leaf nodes in a nested list.

## Usage

``` r
list_nleaf(x)
```

## Arguments

- x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

## Value

A numeric scalar. Integer when possible, double for very large counts.

## See also

Other lstrrr_core:
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md),
[`list_depth()`](https://exceret.github.io/lstrrr/reference/list_depth.md),
[`list_find_value()`](https://exceret.github.io/lstrrr/reference/list_find_value.md),
[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_has()`](https://exceret.github.io/lstrrr/reference/list_has.md),
[`list_path()`](https://exceret.github.io/lstrrr/reference/list_path.md),
[`list_set()`](https://exceret.github.io/lstrrr/reference/list_set.md)

## Examples

``` r
x <- list(a = 1, b = list(c = 2, d = list(e = 3)))
list_nleaf(x)
#> [1] 3

list_nleaf(list())
#> [1] 0
```
