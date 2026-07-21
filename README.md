<!-- README.md is generated from README.Rmd. Please edit that file -->

# lstrrr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/lstrrr)](https://CRAN.R-project.org/package=lstrrr)
[![R-CMD-check](https://github.com/Exceret/lstrrr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Exceret/lstrrr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/Exceret/lstrrr/graph/badge.svg)](https://app.codecov.io/gh/Exceret/lstrrr)
<!-- badges: end -->

lstrrr provides functional programming tools for working with deeply
nested R lists — path-based access, recursive mapping/walking,
conditional modification, and structure visualization. Motivation comes
from [purrr](https://github.com/tidyverse/purrr)

## Installation

``` r
# install.packages("pak")
pak::pak("Exceret/lstrrr")
```

## Core Access

| Function                   | Description                 |
|----------------------------|-----------------------------|
| `list_get(x, path)`        | Read an element by path     |
| `list_set(x, path, value)` | Set an element by path      |
| `list_delete(x, path)`     | Delete an element by path   |
| `list_has(x, path)`        | Check if a path exists      |
| `list_depth(x)`            | Compute nesting depth       |
| `list_path(x)`             | Get paths to all leaf nodes |

## Map & Walk

| Function               | Description                                     |
|------------------------|-------------------------------------------------|
| `list_map(x, .f)`      | Apply `.f` to each leaf, preserving structure   |
| `list_map2(x, y, .f)`  | Map over corresponding leaves of two lists      |
| `list_pmap(.l, .f)`    | Map over corresponding leaves of multiple lists |
| `list_imap(x, .f)`     | Map over leaves with name or full path          |
| `list_walk(x, .f)`     | Walk leaves for side effects                    |
| `list_walk2(x, y, .f)` | Walk corresponding leaves of two lists          |
| `list_pwalk(.l, .f)`   | Walk corresponding leaves of multiple lists     |

## Transformation

| Function | Description |
|----|----|
| `list_flatten(x)` | Flatten into a named list with dot-separated paths |
| `list_find(x, .p)` | Find leaves that satisfy a predicate |
| `list_modify_if(x, .p, .f)` | Modify leaves that satisfy `.p` using `.f` |
| `modify_list(x, val)` | Recursively merge two lists |

## Structure & Visualization

| Function              | Description                                        |
|-----------------------|----------------------------------------------------|
| `list_stats(x)`       | Convert a nested list to tree data (nodes + edges) |
| `viz_list(x)`         | Visualize list structure as a tree diagram         |
| `dir_listwise(paths)` | Convert file paths to a nested list                |

## Example

``` r
library(lstrrr)

x <- list(
  a = 1,
  b = list(x = 2, y = list(i = 3, j = 4))
)

# Path-based access
list_get(x, c("b", "y", "i"))
#> [1] 3

# Recursive mapping
list_map(x, ~ .x * 2)
#> $a
#> [1] 2
#> 
#> $b
#> $b$x
#> [1] 4
#> 
#> $b$y
#> $b$y$i
#> [1] 6
#> 
#> $b$y$j
#> [1] 8

# Flatten with path names
list_flatten(x)
#> $a
#> [1] 1
#> 
#> $b.x
#> [1] 2
#> 
#> $b.y.i
#> [1] 3
#> 
#> $b.y.j
#> [1] 4

# Conditional modification (only values > 2)
list_modify_if(x, ~ is.numeric(.x) && .x > 2, ~ .x * 10)
#> $a
#> [1] 1
#> 
#> $b
#> $b$x
#> [1] 2
#> 
#> $b$y
#> $b$y$i
#> [1] 30
#> 
#> $b$y$j
#> [1] 40

# Tree visualization (requires ggplot2)
# viz_list(x)
```
