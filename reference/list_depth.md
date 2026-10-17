# Compute nested list depth

Compute nested list depth

## Usage

``` r
list_depth(x)
```

## Arguments

- x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

## Value

An integer scalar giving the maximum depth of `x`.

A non-list leaf has depth `0`. A list containing only leaf values has
depth `1`. Deeper nested lists have larger depth according to the
longest path to a leaf.

## See also

Other lstrrr_core:
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md),
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

list_depth(x)
#> [1] 3

# A list with only leaf values has depth 1
list_depth(list(a = 1, b = 2))
#> [1] 1

# Non-list objects are leaves
list_depth(1) # 0
#> [1] 0

# Data frames are treated as leaves
list_depth(list(a = data.frame(x = 1:3)))
#> [1] 1

list_depth(x) # 1
#> [1] 3

```
