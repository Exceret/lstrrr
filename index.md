# lstrrr

lstrrr provides functional programming tools for working with deeply
nested R lists — path-based access, recursive mapping/walking,
conditional modification, and structure visualization. Motivation comes
from [purrr](https://github.com/tidyverse/purrr)

purrr can handle with R list, but it converts R list in to a vector or
atomic, which is not what we want. lstrrr is designed to work with R
list and return the same list structure.

## Installation

``` r

# install.packages("pak")
pak::pak("Exceret/lstrrr")
```

## Getting Started

Use it just like `purrr`

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

## Similar Projects

A similar project is [rlist](https://github.com/renkun-ken/rlist), but
it is not for complex nested list.

Let’s see how they work differently. This is a code snippet from rlist:

``` r

nums <- list(a = c(1, 2, 3), b = c(2, 3, 4), c = c(3, 4, 5))

rlist::list.map(nums, c(min = min(.), max = max(.)))
#> $a
#> min max 
#>   1   3 
#> 
#> $b
#> min max 
#>   2   4 
#> 
#> $c
#> min max 
#>   3   5
rlist::list.filter(nums, x ~ mean(x) >= 3)
#> $b
#> [1] 2 3 4
#> 
#> $c
#> [1] 3 4 5
rlist::list.map(nums, f(x, i) ~ sum(x, i))
#> $a
#> [1] 7
#> 
#> $b
#> [1] 11
#> 
#> $c
#> [1] 15
```

If `nums` becomes a complex nested list, rlist may not work as expected.

``` r

nums <- list(
  a = c(1, 2, 3),
  b = c(2, 3, 4),
  c = c(3, 4, 5),
  d = list(
    e = c(4, 5, 6),
    f = c(5, 6, 7)
  )
)

try(rlist::list.map(nums, c(min = min(.), max = max(.))))
#> Error in min(.) : invalid 'type' (list) of argument
try(rlist::list.filter(nums, x ~ mean(x) >= 3))
#> Warning in mean.default(x): argument is not numeric or logical: returning NA
#> $b
#> [1] 2 3 4
#> 
#> $c
#> [1] 3 4 5
try(rlist::list.map(nums, f(x, i) ~ sum(x, i)))
#> Error in sum(x, i) : invalid 'type' (list) of argument
```

Recursive mapping is the main difference between lstrrr and rlist.
lstrrr views the list as a tree, and recursively applies the function to
leaf nodes.

``` r

list_map(nums, \(v) c(min = min(v), max = max(v)))
#> $a
#> min max 
#>   1   3 
#> 
#> $b
#> min max 
#>   2   4 
#> 
#> $c
#> min max 
#>   3   5 
#> 
#> $d
#> $d$e
#> min max 
#>   4   6 
#> 
#> $d$f
#> min max 
#>   5   7
list_find(nums, ~ mean(.x) >= 3)
#> $b
#> [1] 2 3 4
#> 
#> $c
#> [1] 3 4 5
#> 
#> $d.e
#> [1] 4 5 6
#> 
#> $d.f
#> [1] 5 6 7
list_map(nums, sum)
#> $a
#> [1] 6
#> 
#> $b
#> [1] 9
#> 
#> $c
#> [1] 12
#> 
#> $d
#> $d$e
#> [1] 15
#> 
#> $d$f
#> [1] 18
```
