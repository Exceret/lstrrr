# Flatten a nested list

Flatten a nested list

## Usage

``` r
list_flatten(.x, .sep = ".")
```

## Arguments

- .x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

- .sep:

  Separator used to join path names.

## See also

Other lstrrr-purrrlike:
[`list_filter()`](https://exceret.github.io/lstrrr/reference/list_filter.md),
[`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md),
[`list_iwalk()`](https://exceret.github.io/lstrrr/reference/list_iwalk.md),
[`list_map()`](https://exceret.github.io/lstrrr/reference/list_map.md),
[`list_map2()`](https://exceret.github.io/lstrrr/reference/list_map2.md),
[`list_modify_if()`](https://exceret.github.io/lstrrr/reference/list_modify_if.md),
[`list_pmap()`](https://exceret.github.io/lstrrr/reference/list_pmap.md),
[`list_pwalk()`](https://exceret.github.io/lstrrr/reference/list_pwalk.md),
[`list_walk()`](https://exceret.github.io/lstrrr/reference/list_walk.md),
[`list_walk2()`](https://exceret.github.io/lstrrr/reference/list_walk2.md)
