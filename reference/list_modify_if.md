# Modify leaves satisfying predicate

Modify leaves satisfying predicate

## Usage

``` r
list_modify_if(.x, .p, .f, ...)
```

## Arguments

- .x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

- .p:

  A predicate function, formula, or function-like object coercible by
  [`rlang::as_function()`](https://rlang.r-lib.org/reference/as_function.html).

- .f:

  A function, formula, or function-like object coercible by
  [`rlang::as_function()`](https://rlang.r-lib.org/reference/as_function.html).
  Additional arguments supplied through `...` are passed on to `.f`.

- ...:

  Additional arguments passed to `.f`.

## Value

A nested list with the same structure and names as `x`, where leaves
satisfying `.p` have been replaced by the result of `.f`.

## See also

Other lstrrr-purrrlike:
[`list_filter()`](https://exceret.github.io/lstrrr/reference/list_filter.md),
[`list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md),
[`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md),
[`list_iwalk()`](https://exceret.github.io/lstrrr/reference/list_iwalk.md),
[`list_map()`](https://exceret.github.io/lstrrr/reference/list_map.md),
[`list_map2()`](https://exceret.github.io/lstrrr/reference/list_map2.md),
[`list_pmap()`](https://exceret.github.io/lstrrr/reference/list_pmap.md),
[`list_pwalk()`](https://exceret.github.io/lstrrr/reference/list_pwalk.md),
[`list_walk()`](https://exceret.github.io/lstrrr/reference/list_walk.md),
[`list_walk2()`](https://exceret.github.io/lstrrr/reference/list_walk2.md)

## Examples

``` r
x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  ),
  c = "text"
)

# Double numeric leaves greater than 2
list_modify_if(
  x,
  .p = \(value) is.numeric(value) && value > 2,
  .f = \(value) value * 2
)
#> $a
#> [1] 1
#> 
#> $b
#> $b$x
#> [1] 2
#> 
#> $b$y
#> $b$y$i
#> [1] 6
#> 
#> $b$y$j
#> [1] 8
#> 
#> 
#> 
#> $c
#> [1] "text"
#> 

# Modify only character leaves
list_modify_if(
  x,
  .p = is.character,
  .f = toupper
)
#> $a
#> [1] 1
#> 
#> $b
#> $b$x
#> [1] 2
#> 
#> $b$y
#> $b$y$i
#> [1] 3
#> 
#> $b$y$j
#> [1] 4
#> 
#> 
#> 
#> $c
#> [1] "TEXT"
#> 

# Additional arguments are passed to `.f`
list_modify_if(
  x,
  .p = is.numeric,
  .f = \(value, increment) value + increment,
  increment = 10
)
#> $a
#> [1] 11
#> 
#> $b
#> $b$x
#> [1] 12
#> 
#> $b$y
#> $b$y$i
#> [1] 13
#> 
#> $b$y$j
#> [1] 14
#> 
#> 
#> 
#> $c
#> [1] "text"
#> 

# Data frames are treated as leaves
x2 <- list(a = data.frame(x = 1:3), b = list(c = 1))
list_modify_if(x2, is.data.frame, \(value) transform(value, y = x * 2))
#> $a
#>   x y
#> 1 1 2
#> 2 2 4
#> 3 3 6
#> 
#> $b
#> $b$c
#> [1] 1
#> 
#> 
```
