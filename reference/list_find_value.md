# Find Paths Containing a Given Value

Traverse a nested list and return all paths whose element is identical
to `value`.

## Usage

``` r
list_find_value(x, value)
```

## Arguments

- x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

- value:

  Value to find.

## Value

A list of character vectors, or `NULL` if no match is found.

## See also

Other lstrrr_core:
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md),
[`list_depth()`](https://exceret.github.io/lstrrr/reference/list_depth.md),
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
  b = list(c = 2, d = list(e = 1)),
  list(1)
)

list_find_value(x, 1)
#> [[1]]
#> [1] "a"
#> 
#> [[2]]
#> [1] "b" "d" "e"
#> 
#> [[3]]
#> [1] "3" "1"
#> 
```
