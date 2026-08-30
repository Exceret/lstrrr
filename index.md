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
list_map(x, ~ .x * 2) |> str()
#> List of 2
#>  $ a: num 2
#>  $ b:List of 2
#>   ..$ x: num 4
#>   ..$ y:List of 2
#>   .. ..$ i: num 6
#>   .. ..$ j: num 8

# Flatten with path names
list_flatten(x) |> str()
#> List of 4
#>  $ a    : num 1
#>  $ b.x  : num 2
#>  $ b.y.i: num 3
#>  $ b.y.j: num 4

# Conditional modification (only values > 2)
list_modify_if(x, ~ is.numeric(.x) && .x > 2, ~ .x * 10) |> str()
#> List of 2
#>  $ a: num 1
#>  $ b:List of 2
#>   ..$ x: num 2
#>   ..$ y:List of 2
#>   .. ..$ i: num 30
#>   .. ..$ j: num 40

# Tree visualization (requires ggplot2)
# viz_list(x)
```

## Similar Projects

A similar project is [rlist](https://github.com/renkun-ken/rlist), but
it is not for complex nested list.

Let’s see how they work differently. This is a code snippet from rlist:

``` r

nums <- list(a = c(1, 2, 3), b = c(2, 3, 4), c = c(3, 4, 5))

rlist::list.map(nums, c(min = min(.), max = max(.))) |> str()
#> List of 3
#>  $ a: Named num [1:2] 1 3
#>   ..- attr(*, "names")= chr [1:2] "min" "max"
#>  $ b: Named num [1:2] 2 4
#>   ..- attr(*, "names")= chr [1:2] "min" "max"
#>  $ c: Named num [1:2] 3 5
#>   ..- attr(*, "names")= chr [1:2] "min" "max"
rlist::list.filter(nums, x ~ mean(x) >= 3) |> str()
#> List of 2
#>  $ b: num [1:3] 2 3 4
#>  $ c: num [1:3] 3 4 5
rlist::list.map(nums, f(x, i) ~ sum(x, i)) |> str()
#> List of 3
#>  $ a: num 7
#>  $ b: num 11
#>  $ c: num 15
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

**Recursive mapping is the main difference between lstrrr and rlist**.
lstrrr views the list as a tree, and recursively applies the function to
leaf nodes.

``` r

list_map(nums, \(v) c(min = min(v), max = max(v))) |> str()
#> List of 4
#>  $ a: Named num [1:2] 1 3
#>   ..- attr(*, "names")= chr [1:2] "min" "max"
#>  $ b: Named num [1:2] 2 4
#>   ..- attr(*, "names")= chr [1:2] "min" "max"
#>  $ c: Named num [1:2] 3 5
#>   ..- attr(*, "names")= chr [1:2] "min" "max"
#>  $ d:List of 2
#>   ..$ e: Named num [1:2] 4 6
#>   .. ..- attr(*, "names")= chr [1:2] "min" "max"
#>   ..$ f: Named num [1:2] 5 7
#>   .. ..- attr(*, "names")= chr [1:2] "min" "max"
list_find(nums, ~ mean(.x) >= 3) |> str()
#> List of 4
#>  $ b  : num [1:3] 2 3 4
#>  $ c  : num [1:3] 3 4 5
#>  $ d.e: num [1:3] 4 5 6
#>  $ d.f: num [1:3] 5 6 7
list_map(nums, sum) |> str()
#> List of 4
#>  $ a: num 6
#>  $ b: num 9
#>  $ c: num 12
#>  $ d:List of 2
#>   ..$ e: num 15
#>   ..$ f: num 18
```

------------------------------------------------------------------------

Another similar project is
[rrapply](https://github.com/JorisChau/rrapply/), which also provide
list recursion in R.

``` r

dat <- list(
  user = list(
    name = "alice",
    age = 20,
    scores = list(
      math = 80,
      english = 90
    )
  ),
  status = "active"
)
```

``` r

result1 <- rrapply::rrapply(
  dat,
  f = function(x) x + 5,
  classes = "numeric",
  condition = function(x) x >= 80
)
str(result1)
#> List of 2
#>  $ user  :List of 3
#>   ..$ name  : chr "alice"
#>   ..$ age   : num 20
#>   ..$ scores:List of 2
#>   .. ..$ math   : num 85
#>   .. ..$ english: num 95
#>  $ status: chr "active"
```

``` r

result2 <- list_modify_if(dat, ~ is.numeric(.x) & .x >= 80, ~ .x + 5)
str(result2)
#> List of 2
#>  $ user  :List of 3
#>   ..$ name  : chr "alice"
#>   ..$ age   : num 20
#>   ..$ scores:List of 2
#>   .. ..$ math   : num 85
#>   .. ..$ english: num 95
#>  $ status: chr "active"
```

The differences between `lstrrr` and `rrapply` are as follows:

1.  `lstrrr` follows the design philosophy of
    [purrr](https://github.com/tidyverse/purrr), whereas `rrapply` is
    based on base R’s [`rapply()`](https://rdrr.io/r/base/rapply.html).
2.  lstrrr provides a native progress bar similar to the one in purrr
    (using [cli](https://github.com/r-lib/cli) C API).
3.  lstrrr provides several basic functions for working with nested
    lists, such as
    [`list_set()`](https://exceret.github.io/lstrrr/reference/list_set.md),
    [`list_get()`](https://exceret.github.io/lstrrr/reference/list_get.md),
    and
    [`list_nleaf()`](https://exceret.github.io/lstrrr/reference/list_nleaf.md).

------------------------------------------------------------------------

To see more examples, click
[here](https://exceret.github.io/lstrrr/index.html)
