# Get all leaf paths in a nested list

Get all leaf paths in a nested list

## Usage

``` r
list_path(x)
```

## Arguments

- x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

## Value

A list of character vectors.

Each element of the returned list is the path to one leaf value in `x`.
If `x` has no leaves, an empty list is returned.

## See also

[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_has()`](https://exceret.github.io/lstrrr/reference/list_has.md)

Other lstrrr_core:
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md),
[`list_depth()`](https://exceret.github.io/lstrrr/reference/list_depth.md),
[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_has()`](https://exceret.github.io/lstrrr/reference/list_has.md),
[`list_nleaf()`](https://exceret.github.io/lstrrr/reference/list_nleaf.md),
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

res <- list_path(x)
res
#> [[1]]
#> [1] "a"
#> 
#> [[2]]
#> [1] "b" "x"
#> 
#> [[3]]
#> [1] "b" "y" "i"
#> 
#> [[4]]
#> [1] "b" "y" "j"
#> 

# The paths can be used with list_get()
lapply(res, \(path) list_get(x, path))
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] 1
#> 
#> [[3]]
#> [1] 1
#> 
#> [[4]]
#> [1] 2
#> 

# Top-level leaves have paths of length 1
list_path(list(a = 1, b = 2))
#> [[1]]
#> [1] "a"
#> 
#> [[2]]
#> [1] "b"
#> 

# Unnamed elements use their position as character labels
list_path(list(10, list(20, z = 30)))
#> [[1]]
#> [1] "1"
#> 
#> [[2]]
#> [1] "2" "1"
#> 
#> [[3]]
#> [1] "2" "z"
#> 

# Data frames are treated as leaves
list_path(list(a = data.frame(x = 1:3), b = list(c = 1)))
#> [[1]]
#> [1] "a"
#> 
#> [[2]]
#> [1] "b" "c"
#> 


```
