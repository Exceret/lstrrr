# Walk over leaves of multiple nested lists

Applies `.f` to corresponding leaves of multiple nested lists for side
effects.

## Usage

``` r
list_pwalk(.l, .f, ..., .progress = FALSE)
```

## Arguments

- .l:

  A list of nested lists.

- .f:

  A function, formula, or function-like object coercible by
  [`rlang::as_function()`](https://rlang.r-lib.org/reference/as_function.html).
  Additional arguments supplied through `...` are passed on to `.f`.

- ...:

  Additional arguments passed to `.f`.

- .progress:

  Whether to show a progress

  Use TRUE to turn on a basic progress, use a string to give it a name

## Value

Invisibly returns `.l`.

## See also

Other lstrrr-purrrlike:
[`list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md),
[`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md),
[`list_iwalk()`](https://exceret.github.io/lstrrr/reference/list_iwalk.md),
[`list_map()`](https://exceret.github.io/lstrrr/reference/list_map.md),
[`list_map2()`](https://exceret.github.io/lstrrr/reference/list_map2.md),
[`list_modify_if()`](https://exceret.github.io/lstrrr/reference/list_modify_if.md),
[`list_pmap()`](https://exceret.github.io/lstrrr/reference/list_pmap.md),
[`list_walk()`](https://exceret.github.io/lstrrr/reference/list_walk.md),
[`list_walk2()`](https://exceret.github.io/lstrrr/reference/list_walk2.md)

## Examples

``` r
# \donttest{
x <- list(
  a = 1,
  b = list(
    x = 1,
    y = list(i = 1, j = 2)
  )
)
list_pmap(list(x,x,x), function(x,y,z) (x + y) *z)
#> $a
#> [1] 2
#> 
#> $b
#> $b$x
#> [1] 2
#> 
#> $b$y
#> $b$y$i
#> [1] 2
#> 
#> $b$y$j
#> [1] 8
#> 
#> 
#> 
# $a
# [1] 2
#
# $b
# $b$x
# [1] 2
#
# $b$y
# $b$y$i
# [1] 2
#
# $b$y$j
# [1] 8

# }
```
