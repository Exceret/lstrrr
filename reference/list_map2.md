# Map over leaves of two nested lists

Map over leaves of two nested lists

## Usage

``` r
list_map2(.x, .y, .f, ..., .progress = FALSE)
```

## Arguments

- .x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

- .y:

  A nested list. Must have the same structure as `.x`.

- .f:

  A function, formula, or function-like object coercible by
  [`rlang::as_function()`](https://rlang.r-lib.org/reference/as_function.html).
  Additional arguments supplied through `...` are passed on to `.f`.

- ...:

  Additional arguments passed to `.f`.

- .progress:

  Whether to show a progress

  Use TRUE to turn on a basic progress, use a string to give it a name,
  or use a list to customize the progress bar (see
  [`?cli::cli_progress_bar`](https://cli.r-lib.org/reference/cli_progress_bar.html)
  and
  https://cli.r-lib.org/articles/progress-advanced.html#cli_progress_bar
  for details).

## See also

Other lstrrr-purrrlike:
[`list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md),
[`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md),
[`list_iwalk()`](https://exceret.github.io/lstrrr/reference/list_iwalk.md),
[`list_map()`](https://exceret.github.io/lstrrr/reference/list_map.md),
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
    x = 1,
    y = list(i = 1, j = 2)
  )
)
x2 <- list_map2(x, x, ~ {.x + .y})
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
# [1] 4
# }
```
