# Rename a nested element by path

Renames the last slot of `path`, leaving the elements themselves
untouched.

## Usage

``` r
list_rename(x, path, name)
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

- name:

  A single string giving the new name for the element located at the end
  of `path`.

## Value

A modified copy of `x` with the element at `path` renamed.

If `path` does not exist, or if the parent of the last slot is not a
list, `x` is returned unchanged. Renaming only affects names: the
elements of `x` are shared with the original object rather than
duplicated.

## See also

[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_set()`](https://exceret.github.io/lstrrr/reference/list_set.md),
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md)

Other lstrrr_core:
[`list_delete()`](https://exceret.github.io/lstrrr/reference/list_delete.md),
[`list_depth()`](https://exceret.github.io/lstrrr/reference/list_depth.md),
[`list_find_value()`](https://exceret.github.io/lstrrr/reference/list_find_value.md),
[`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
[`list_has()`](https://exceret.github.io/lstrrr/reference/list_has.md),
[`list_nleaf()`](https://exceret.github.io/lstrrr/reference/list_nleaf.md),
[`list_path()`](https://exceret.github.io/lstrrr/reference/list_path.md),
[`list_set()`](https://exceret.github.io/lstrrr/reference/list_set.md)

## Examples

``` r
x <- list(
  a = 1,
  b = list(
    c = 2,
    d = list(e = 3)
  )
)

list_rename(x, c("b", "d", "e"), "renamed")
#> $a
#> [1] 1
#> 
#> $b
#> $b$c
#> [1] 2
#> 
#> $b$d
#> $b$d$renamed
#> [1] 3
#> 
#> 
#> 

# Integer paths use positional indices
list_rename(x, c(2L, 2L, 1L), "renamed")
#> $a
#> [1] 1
#> 
#> $b
#> $b$c
#> [1] 2
#> 
#> $b$d
#> $b$d$renamed
#> [1] 3
#> 
#> 
#> 

# Missing paths leave `x` unchanged
list_rename(x, c("b", "missing"), "renamed")
#> $a
#> [1] 1
#> 
#> $b
#> $b$c
#> [1] 2
#> 
#> $b$d
#> $b$d$e
#> [1] 3
#> 
#> 
#> 

# Empty path has nothing to rename
list_rename(x, character(0), "renamed")
#> $a
#> [1] 1
#> 
#> $b
#> $b$c
#> [1] 2
#> 
#> $b$d
#> $b$d$e
#> [1] 3
#> 
#> 
#> 

# The original object is unchanged unless reassigned
x2 <- list_rename(x, c("b", "d", "e"), "renamed")
names(x$b$d)
#> [1] "e"
names(x2$b$d)
#> [1] "renamed"
```
