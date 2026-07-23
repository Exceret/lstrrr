# Walk over leaves of two nested lists

Applies `.f` to corresponding leaves of `.x` and `.y` for side effects.

## Usage

``` r
list_iwalk(.x, .f, ..., .progress = FALSE)
```

## Arguments

- .x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

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

Invisibly returns `.x`.

## See also

Other lstrrr-purrrlike:
[`list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md),
[`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md),
[`list_map()`](https://exceret.github.io/lstrrr/reference/list_map.md),
[`list_map2()`](https://exceret.github.io/lstrrr/reference/list_map2.md),
[`list_modify_if()`](https://exceret.github.io/lstrrr/reference/list_modify_if.md),
[`list_pmap()`](https://exceret.github.io/lstrrr/reference/list_pmap.md),
[`list_pwalk()`](https://exceret.github.io/lstrrr/reference/list_pwalk.md),
[`list_walk()`](https://exceret.github.io/lstrrr/reference/list_walk.md),
[`list_walk2()`](https://exceret.github.io/lstrrr/reference/list_walk2.md)

## Examples

``` r
# \donttest{
x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  ),
  unnamed = list(5, z = 6)
)

# Pass only the leaf name or positional index
list_imap(x, \(value, name) paste(name, value, sep = " = "))
#> $a
#> [1] "a = 1"
#> 
#> $b
#> $b$x
#> [1] "x = 2"
#> 
#> $b$y
#> $b$y$i
#> [1] "i = 3"
#> 
#> $b$y$j
#> [1] "j = 4"
#> 
#> 
#> 
#> $unnamed
#> $unnamed[[1]]
#> [1] "1 = 5"
#> 
#> $unnamed$z
#> [1] "z = 6"
#> 
#> 

# Pass the full path to each leaf
list_imap(
  x,
  \(value, path) paste(paste(path, collapse = "."), value, sep = " = "),
  .name = "path"
)
#> $a
#> [1] "a = 1"
#> 
#> $b
#> $b$x
#> [1] "b.x = 2"
#> 
#> $b$y
#> $b$y$i
#> [1] "b.y.i = 3"
#> 
#> $b$y$j
#> [1] "b.y.j = 4"
#> 
#> 
#> 
#> $unnamed
#> $unnamed[[1]]
#> [1] "unnamed.1 = 5"
#> 
#> $unnamed$z
#> [1] "unnamed.z = 6"
#> 
#> 

# Additional arguments are forwarded to `.f`
list_imap(
  x,
  \(value, name, prefix) paste0(prefix, name, ": ", value),
  prefix = "leaf_"
)
#> $a
#> [1] "leaf_a: 1"
#> 
#> $b
#> $b$x
#> [1] "leaf_x: 2"
#> 
#> $b$y
#> $b$y$i
#> [1] "leaf_i: 3"
#> 
#> $b$y$j
#> [1] "leaf_j: 4"
#> 
#> 
#> 
#> $unnamed
#> $unnamed[[1]]
#> [1] "leaf_1: 5"
#> 
#> $unnamed$z
#> [1] "leaf_z: 6"
#> 
#> 

# Data frames are treated as leaves
x2 <- list(a = data.frame(x = 1:3), b = list(c = 1))
list_imap(x2, \(value, path) path, .name = "path")
#> $a
#> [1] "a"
#> 
#> $b
#> $b$c
#> [1] "b" "c"
#> 
#> 

# }
```
