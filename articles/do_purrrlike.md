# Use lstrrr to do some purrr-like things

## TL;DR

### Core Access

| Function                   | Description                 |
|----------------------------|-----------------------------|
| `list_get(x, path)`        | Read an element by path     |
| `list_set(x, path, value)` | Set an element by path      |
| `list_delete(x, path)`     | Delete an element by path   |
| `list_has(x, path)`        | Check if a path exists      |
| `list_depth(x)`            | Compute nesting depth       |
| `list_path(x)`             | Get paths to all leaf nodes |

### Map & Walk

| Function                 | Description                                     |
|--------------------------|-------------------------------------------------|
| `list_map(.x, .f)`       | Apply `.f` to each leaf, preserving structure   |
| `list_map2(.x, .y, .f)`  | Map over corresponding leaves of two lists      |
| `list_pmap(.l, .f)`      | Map over corresponding leaves of multiple lists |
| `list_imap(.x, .f)`      | Map over leaves with name or full path          |
| `list_walk(.x, .f)`      | Walk leaves for side effects                    |
| `list_walk2(.x, .y, .f)` | Walk corresponding leaves of two lists          |
| `list_pwalk(.l, .f)`     | Walk corresponding leaves of multiple lists     |
| `list_iwalk(.x, .f)`     | Walk over leaves with name or full path         |

### Transformation

| Function | Description |
|----|----|
| `list_flatten(.x)` | Flatten into a named list with dot-separated paths |
| `list_find(.x, .p)` | Find leaves that satisfy a predicate |
| `list_modify_if(.x, .p, .f)` | Modify leaves that satisfy `.p` using `.f` |

## Introduction

lstrrr is designed to be a
[purrr](https://github.com/tidyverse/purrr)-like package handling nested
lists. `purrr` also comes with some built-in functions for handling
lists, which can be used alongside `lstrrr` to better serve practical
needs.

## Core Access

`lstrrr` use vector to represent the path to the element,
e.g. `c("a", "b", "c")`, which is similar to the `$` operator in R.

![](do_purrrlike_files/figure-html/foo.svg)

``` r

list_get(foo, c("a", "b", "d"))
```

![](do_purrrlike_files/figure-html/list_get.svg)

``` r

list_set(foo, c("a", "b", "d"), TRUE) |> str()
```

![](do_purrrlike_files/figure-html/list_set.svg)

Other functions like `list_delete(x, path)`, `list_has(x, path)`,
`list_depth(x)`, `list_path(x)` are self-explanatory.

## List Conversion

Let’s use the build-in dataset `sputnik_1` as an example:

``` r

list_nleaf(sputnik_1)
```

![](do_purrrlike_files/figure-html/list_nleaf.svg)

You can use
[`list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md)
to flatten a nested list into a flattened list (the elements of the list
are not nested):

``` r

v <- list_flatten(sputnik_1)
head(v, 3)
```

![](do_purrrlike_files/figure-html/list_flatten.svg)

``` r

cli::cli_alert_info("Class of v: {.cls {class(v)}}")
cli::cli_alert_info("Length of v: {.val {length(v)}} (using {.fun length})")
cli::cli_alert_info(
  "Length of v: {.val {list_nleaf(v)}} (using {.fun list_nleaf})"
)
```

![](do_purrrlike_files/figure-html/list_flatten_info.svg)

The names of the elements are the dot-separated paths to the elements:

``` r

head(names(v))
```

![](do_purrrlike_files/figure-html/list_flatten_names.svg)

Separation symbols can be customized. Generally I don’t recommend using
`_` as purrr does, because it’s a common separator in names.

``` r

v2 <- list_flatten(sputnik_1, "$")
head(names(v2))
```

![](do_purrrlike_files/figure-html/dollar_sep.svg)

**Recursive mapping is the main difference between
[`lstrrr::list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md)
and
[`purrr::list_flatten()`](https://purrr.tidyverse.org/reference/list_flatten.html).**,
the former will flatten all levels of the list, while the latter will
flatten the second level of the list (the first level is the list
itself).

``` r

v3 <- purrr::list_flatten(sputnik_1, is_node = is.list)
head(v, 3)
```

![](do_purrrlike_files/figure-html/purrr_list_flatten.svg)

``` r

cli::cli_alert_info("Class of v3: {.cls {class(v3)}}")
cli::cli_alert_info("Length of v3: {.val {length(v3)}} (using {.fun length})")
cli::cli_alert_info(
  "Length of v3: {.val {list_nleaf(v3)}} (using {.fun list_nleaf})"
)
```

![](do_purrrlike_files/figure-html/purrr_list_flatten_info.svg)

## Functional Programming

lstrrr provides a set of functions that are similar to `purrr`’s, but
for handling nested lists. Just use `list_*` as the prefix of the
function name.

``` r

foo <- list(a = 1, b = list(c = "a", d = FALSE))

list_map(foo, \(x) typeof(x)) |> str()
```

![](do_purrrlike_files/figure-html/list_map.svg)

``` r

list_imap(foo, ~ paste(.y, ":", .x)) |> str()
```

![](do_purrrlike_files/figure-html/list_imap.svg)

If you want to map over multiple lists, make sure the lists have the
same structure.

``` r

list_walk2(foo, foo, ~ message(paste0(.x, .y)))
```

![](do_purrrlike_files/figure-html/list_walk2.svg)

``` r

list_pwalk(
  list(foo, foo, foo),
  \(x, y, z) {
    Sys.sleep(0.5)
  },
  .progress = "pwalk"
)
```

![](do_purrrlike_files/figure-html/list_pwalk.svg)

Customize the progress bar:

``` r

list_walk(
  sputnik_1,
  ~ Sys.sleep(0.05),
  .progress = list(name = "foo", type = "download")
)
```

![](do_purrrlike_files/figure-html/list_walk.svg)

[`list_find()`](https://exceret.github.io/lstrrr/reference/list_find.md)
is used to find elements that satisfy a predicate. Please note that the
result is a list with only 1 level.

``` r

list_find(foo, ~ is.character(.x)) |> str()
```

![](do_purrrlike_files/figure-html/list_find.svg)

`list_modify_if` is used to modify elements that satisfy a predicate.
The structure of the list is preserved.

``` r

list_modify_if(foo, is.logical, ~ !.x) |> str()
```

![](do_purrrlike_files/figure-html/list_modify_if.svg)
