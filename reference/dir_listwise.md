# Convert File Paths to a Nested List

Convert character paths, usually returned by
[`list.files()`](https://rdrr.io/r/base/list.files.html), to a nested
list structure.

## Usage

``` r
dir_listwise(
  paths,
  value = c("path", "name", "TRUE"),
  sep = "[/\\\\]+",
  simplify_empty = TRUE
)
```

## Arguments

- paths:

  A character vector of file paths.

- value:

  What to store at leaf nodes. One of `"path"`, `"name"`, or `"TRUE"`.

- sep:

  Path separator (regex). Defaults to `/` and `\\`.

- simplify_empty:

  Logical. If `TRUE`, empty path components are removed.

## Value

A nested named list.

## Examples

``` r
# \donttest{
paths <- c(
  "R/list-core.R",
  "R/viz-list.R",
  "src/init.c",
  "src/list_core.c",
  "DESCRIPTION"
)

dir_listwise(paths)
#> $R
#> $R$`list-core.R`
#> [1] "R/list-core.R"
#> 
#> $R$`viz-list.R`
#> [1] "R/viz-list.R"
#> 
#> 
#> $src
#> $src$init.c
#> [1] "src/init.c"
#> 
#> $src$list_core.c
#> [1] "src/list_core.c"
#> 
#> 
#> $DESCRIPTION
#> [1] "DESCRIPTION"
#> 
# }
```
