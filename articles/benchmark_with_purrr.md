# Performance Benchmarking

``` r

library(lstrrr)
#> ✔ lstrrr v0.1.0 loaded
data(sputnik_1)
```

## Map & Walk

Here, we will use a simple example to illustrate the performance
difference of `lstrrr`.

``` r

files <- list.files(all.files = TRUE, recursive = TRUE)
files_list <- dir_listwise(files)
```

``` r

slow_string_op <- function(x, n = 10) {
  stopifnot(is.character(x))

  out <- x

  for (i in seq_len(n)) {
    out <- paste0(
      rev(strsplit(out, "", fixed = TRUE)[[1]]),
      collapse = ""
    )
    out <- toupper(out)
    out <- tolower(out)
  }

  out
}

set.seed(123)

bench_map <- microbenchmark::microbenchmark(
  purrr_10 = {
    purrr::walk(files, \(x) slow_string_op(x))
  },
  lstrrr_10 = {
    list_walk(files_list, \(x) slow_string_op(x))
  },
  purrr_50 = {
    purrr::walk(files, \(x) slow_string_op(x, n = 50))
  },
  lstrrr_50 = {
    list_walk(files_list, \(x) slow_string_op(x, n = 50))
  },
  purrr_100 = {
    purrr::walk(files, \(x) slow_string_op(x, n = 100))
  },
  lstrrr_100 = {
    list_walk(files_list, \(x) slow_string_op(x, n = 100))
  }
)
print(bench_map)
#> Unit: milliseconds
#>        expr       min        lq      mean    median        uq       max neval
#>    purrr_10  4.386583  4.498742  5.308452  4.532184  4.580127 58.562837   100
#>   lstrrr_10  4.278536  4.402751  4.617510  4.433165  4.466600  9.249905   100
#>    purrr_50 20.818977 21.397637 23.069671 21.593987 21.882532 77.460625   100
#>   lstrrr_50 20.899197 21.250135 22.159566 21.383241 21.523437 26.321512   100
#>   purrr_100 41.876719 42.727721 44.747534 43.009698 47.136634 57.044835   100
#>  lstrrr_100 41.465815 42.610461 44.749231 43.146925 46.959363 50.534691   100
```

``` r

ggplot2::autoplot(bench_map) +
  ggplot2::theme(axis.text = ggplot2::element_text(size = 12))
#> Warning: `aes_string()` was deprecated in ggplot2 3.0.0.
#> ℹ Please use tidy evaluation idioms with `aes()`.
#> ℹ See also `vignette("ggplot2-in-packages")` for more information.
#> ℹ The deprecated feature was likely used in the microbenchmark package.
#>   Please report the issue at
#>   <https://github.com/joshuaulrich/microbenchmark/issues/>.
#> This warning is displayed once per session.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
```

![](benchmark_with_purrr_files/figure-html/viz_map-1.png)

## Detect Depth

``` r

set.seed(124)

bench_depth <- microbenchmark::microbenchmark(
  purrr = {
    purrr::pluck_depth(sputnik_1)
  },
  lstrrr = {
    list_depth(sputnik_1)
  }
)
print(bench_depth)
#> Unit: microseconds
#>    expr      min        lq       mean   median       uq      max neval
#>   purrr 4957.287 5012.0360 5309.19611 5073.457 5244.338 8439.396   100
#>  lstrrr    2.188    2.3375    4.94177    4.744    6.036   42.903   100
```

``` r

ggplot2::autoplot(bench_depth) +
  ggplot2::theme(axis.text = ggplot2::element_text(size = 12))
```

![](benchmark_with_purrr_files/figure-html/viz_depth-1.png)

## Assignment

``` r

set.seed(125)

bench_assign <- microbenchmark::microbenchmark(
  purrr = {
    purrr::list_assign(sputnik_1, z = list(a = 1:5))
  },
  lstrrr = {
    list_set(sputnik_1, c("z"), list(a = 1:5))
  }
)
print(bench_assign)
#> Unit: microseconds
#>    expr    min      lq     mean  median      uq     max neval
#>   purrr 19.181 19.6170 23.84828 19.9765 21.1745 335.235   100
#>  lstrrr  1.897  2.0355  2.36511  2.1780  2.3115  16.964   100
```

``` r

ggplot2::autoplot(bench_assign) +
  ggplot2::theme(axis.text = ggplot2::element_text(size = 12))
```

![](benchmark_with_purrr_files/figure-html/viz_assign-1.png)

## Modification

``` r

set.seed(126)

bench_modify <- microbenchmark::microbenchmark(
  purrr = {
    purrr::list_modify(sputnik_1, test_branches = list(null_leaf = 1:5))
  },
  lstrrr = {
    list_set(sputnik_1, c("test_branches", "null_leaf"), 1:5)
  }
)
print(bench_modify)
#> Unit: microseconds
#>    expr    min      lq     mean  median     uq     max neval
#>   purrr 33.544 34.5885 39.69775 38.5295 39.387 178.738   100
#>  lstrrr  1.749  1.9515  2.26416  2.1075  2.322  14.445   100
```

``` r

ggplot2::autoplot(bench_modify) +
  ggplot2::theme(axis.text = ggplot2::element_text(size = 12))
```

![](benchmark_with_purrr_files/figure-html/viz_modify-1.png)

## Flatten

``` r

set.seed(127)

bench_flatten <- microbenchmark::microbenchmark(
  purrr = {
    purrr::list_flatten(sputnik_1)
  },
  lstrrr = {
    list_flatten(sputnik_1)
  }
)
print(bench_flatten)
#> Unit: microseconds
#>    expr      min        lq      mean   median       uq      max neval
#>   purrr 1154.116 1206.8905 1284.2418 1251.312 1287.039 4033.056   100
#>  lstrrr   30.163   35.3225   42.3614   42.610   46.854   95.566   100
```

``` r

ggplot2::autoplot(bench_flatten) +
  ggplot2::theme(axis.text = ggplot2::element_text(size = 12))
```

![](benchmark_with_purrr_files/figure-html/viz_flatten-1.png)

## modifyList

``` r

set.seed(128)

foo <- sputnik_1
foo$test_branches$empty_branch$score <- 1e-256

bench_modify_list <- microbenchmark::microbenchmark(
  utils = {
    utils::modifyList(sputnik_1, foo)
  },
  lstrrr = {
    modify_list(sputnik_1, foo)
  }
)
print(bench_modify_list)
#> Unit: microseconds
#>    expr     min       lq      mean   median       uq      max neval
#>   utils 692.182 721.5445 769.88172 733.4005 758.1820 3478.448   100
#>  lstrrr  16.263  17.1975  19.50171  18.5010  19.6955   81.100   100
```

``` r

ggplot2::autoplot(bench_modify_list) +
  ggplot2::theme(axis.text = ggplot2::element_text(size = 12))
```

![](benchmark_with_purrr_files/figure-html/viz_modify_list-1.png)

## Parallel Computation

Most of logic is in C implementation, so the acceleration is not that
obvious.

``` r

set.seed(129)
mirai::daemons(3L)
crate <- purrr::in_parallel(
  \(x) {
    slow_string_op(x, n = 10)
  },
  slow_string_op = slow_string_op
)
fn <- function(x) {
  slow_string_op(x, n = 10)
}

bench_parallel <- microbenchmark::microbenchmark(
  lstrrr_parallel = {
    list_map(files_list, crate)
  },
  lstrrr = {
    list_map(files_list, fn)
  },
  purrr = {
    purrr::map(files, fn)
  },
  purrr_parallel = {
    purrr::map(files, crate)
  }
)
mirai::daemons(0L)
print(bench_parallel)
#> Unit: milliseconds
#>             expr      min       lq      mean    median        uq      max neval
#>  lstrrr_parallel 4.560180 4.658508  4.926311  4.700740  4.774752 12.78571   100
#>           lstrrr 4.333456 4.407796  4.665749  4.456909  4.511870 10.95009   100
#>            purrr 4.399958 4.467871  4.668472  4.507328  4.591276 11.12772   100
#>   purrr_parallel 8.820234 9.982046 10.535187 10.339956 10.878160 15.62690   100
```

``` r

ggplot2::autoplot(bench_parallel) +
  ggplot2::theme(axis.text = ggplot2::element_text(size = 12))
```

![](benchmark_with_purrr_files/figure-html/viz_parallel-1.png)
