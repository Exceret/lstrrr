# Use lstrrr to do some purrr-like things

``` r

library(lstrrr)
#> ✔ lstrrr v0.1.0 loaded
```

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

``` r

foo <- list(a = list(b = list(c = "a", d = FALSE)))
```

``` r

list_get(foo, c("a", "b", "d"))
#> [1] FALSE
```

``` r

list_set(foo, c("a", "b", "d"), TRUE) |> str()
#> List of 1
#>  $ a:List of 1
#>   ..$ b:List of 2
#>   .. ..$ c: chr "a"
#>   .. ..$ d: logi TRUE
```

Other functions like `list_delete(x, path)`, `list_has(x, path)`,
`list_depth(x)`, `list_path(x)` are self-explanatory.

## List Conversion

Let’s use the build-in dataset `sputnik_1` as an example:

``` r

list_nleaf(sputnik_1)
#> [1] 104
```

You can use
[`list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md)
to flatten a nested list into a flattened list (the elements of the list
are not nested):

``` r

v <- list_flatten(sputnik_1)
head(v, 3)
#> $meta.dataset
#> [1] "sputnik_1"
#> 
#> $meta.title
#> [1] "Sputnik 1 mission and spacecraft information"
#> 
#> $meta.description
#> [1] "A nested list collecting structured historical, technical, orbital, and cultural information about Sputnik 1, the first artificial Earth satellite."
```

``` r

cli::cli_alert_info("Class of v: {.cls {class(v)}}")
#> ℹ Class of v: <list>
cli::cli_alert_info("Length of v: {.val {length(v)}} (using {.fun length})")
#> ℹ Length of v: 104 (using `length()`)
cli::cli_alert_info(
  "Length of v: {.val {list_nleaf(v)}} (using {.fun list_nleaf})"
)
#> ℹ Length of v: 104 (using `list_nleaf()`)
```

The names of the elements are the dot-separated paths to the elements:

``` r

head(names(v))
#> [1] "meta.dataset"     "meta.title"       "meta.description" "meta.language"   
#> [5] "meta.created"     "meta.sources"
```

Separation symbols can be customized. Generally I don’t recommend using
`_`, because it’s a common separator in names.

``` r

v2 <- list_flatten(sputnik_1, "$")
head(names(v2))
#> [1] "meta$dataset"     "meta$title"       "meta$description" "meta$language"   
#> [5] "meta$created"     "meta$sources"
```

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
#> $meta.dataset
#> [1] "sputnik_1"
#> 
#> $meta.title
#> [1] "Sputnik 1 mission and spacecraft information"
#> 
#> $meta.description
#> [1] "A nested list collecting structured historical, technical, orbital, and cultural information about Sputnik 1, the first artificial Earth satellite."
```

``` r

cli::cli_alert_info("Class of v3: {.cls {class(v3)}}")
#> ℹ Class of v3: <list>
cli::cli_alert_info("Length of v3: {.val {length(v3)}} (using {.fun length})")
#> ℹ Length of v3: 40 (using `length()`)
cli::cli_alert_info(
  "Length of v3: {.val {list_nleaf(v3)}} (using {.fun list_nleaf})"
)
#> ℹ Length of v3: 109 (using `list_nleaf()`)
```

## Functional Programming

lstrrr provides a set of functions that are similar to `purrr`’s, but
for handling nested lists. Just use `list_*` as the prefix of the
function name.

``` r

foo <- list(a = 1, b = list(c = "a", d = FALSE))

list_map(foo, \(x) typeof(x)) |> str()
#> List of 2
#>  $ a: chr "double"
#>  $ b:List of 2
#>   ..$ c: chr "character"
#>   ..$ d: chr "logical"
```

``` r

list_imap(foo, ~ paste(.y, ":", .x)) |> str()
#> List of 2
#>  $ a: chr "a : 1"
#>  $ b:List of 2
#>   ..$ c: chr "c : a"
#>   ..$ d: chr "d : FALSE"
```

``` r

list_walk2(foo, foo, ~ message(paste0(.x, .y)))
#> 11
#> aa
#> FALSEFALSE
```

``` r

list_pwalk(
  list(foo, foo, foo),
  \(x, y, z) {
    message(paste0(x, y, z))
    Sys.sleep(0.5)
  },
  .progress = "pwalk"
)
#> ⠋ pwalk 0/3 (  0%)   ⠙ pwalk 1/3 ( 33%)
#> 111
#> ⠹ pwalk 2/3 ( 67%)
#> aaa
#> ⠸ pwalk 3/3 (100%)
#> FALSEFALSEFALSE
#> ✔ pwalk 3/3 (100%)
```

[`list_find()`](https://exceret.github.io/lstrrr/reference/list_find.md)
is used to find elements that satisfy a predicate. Please note that the
result is a list with only 1 level.

``` r

list_find(foo, ~ is.character(.x)) |> str()
#> List of 1
#>  $ b.c: chr "a"
```

``` r

list_modify_if(foo, is.logical, ~ !.x) |> str()
#> List of 2
#>  $ a: num 1
#>  $ b:List of 2
#>   ..$ c: chr "a"
#>   ..$ d: logi TRUE
```
