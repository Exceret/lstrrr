# Map over leaves of a nested list

Map over leaves of a nested list

## Usage

``` r
list_map(.x, .f, ..., .progress = FALSE)
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

  Use TRUE to turn on a basic progress, use a string to give it a name,
  or use a list to customize the progress bar (see
  [`?cli::cli_progress_bar`](https://cli.r-lib.org/reference/cli_progress_bar.html)
  and
  https://cli.r-lib.org/articles/progress-advanced.html#cli_progress_bar
  for details).

## Value

A list with the same nested structure as `.x`, where each leaf has been
replaced by the result of calling `.f` on that leaf.

## See also

Other lstrrr-purrrlike:
[`list_flatten()`](https://exceret.github.io/lstrrr/reference/list_flatten.md),
[`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md),
[`list_iwalk()`](https://exceret.github.io/lstrrr/reference/list_iwalk.md),
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
    x = 1,
    y = list(i = 1, j = 2)
  )
)
x2 <- list_map(x, function(x) x - 2)
# $a
# [1] -1
#
# $b
# $b$x
# [1] -1
#
# $b$y
# $b$y$i
# [1] -1
#
# $b$y$j
# [1] 0
# }
```
