## TL;DR

### Core Access

<table>
<thead>
<tr>
<th>Function</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>list_get(x, path)</code></td>
<td>Read an element by path</td>
</tr>
<tr>
<td><code>list_set(x, path, value)</code></td>
<td>Set an element by path</td>
</tr>
<tr>
<td><code>list_delete(x, path)</code></td>
<td>Delete an element by path</td>
</tr>
<tr>
<td><code>list_has(x, path)</code></td>
<td>Check if a path exists</td>
</tr>
<tr>
<td><code>list_depth(x)</code></td>
<td>Compute nesting depth</td>
</tr>
<tr>
<td><code>list_path(x)</code></td>
<td>Get paths to all leaf nodes</td>
</tr>
</tbody>
</table>

### Map & Walk

<table>
<colgroup>
<col style="width: 32%" />
<col style="width: 67%" />
</colgroup>
<thead>
<tr>
<th>Function</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>list_map(.x, .f)</code></td>
<td>Apply <code>.f</code> to each leaf, preserving structure</td>
</tr>
<tr>
<td><code>list_map2(.x, .y, .f)</code></td>
<td>Map over corresponding leaves of two lists</td>
</tr>
<tr>
<td><code>list_pmap(.l, .f)</code></td>
<td>Map over corresponding leaves of multiple lists</td>
</tr>
<tr>
<td><code>list_imap(.x, .f)</code></td>
<td>Map over leaves with name or full path</td>
</tr>
<tr>
<td><code>list_walk(.x, .f)</code></td>
<td>Walk leaves for side effects</td>
</tr>
<tr>
<td><code>list_walk2(.x, .y, .f)</code></td>
<td>Walk corresponding leaves of two lists</td>
</tr>
<tr>
<td><code>list_pwalk(.l, .f)</code></td>
<td>Walk corresponding leaves of multiple lists</td>
</tr>
<tr>
<td><code>list_iwalk(.x, .f)</code></td>
<td>Walk over leaves with name or full path</td>
</tr>
</tbody>
</table>

### Transformation

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<thead>
<tr>
<th>Function</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><code>list_flatten(.x)</code></td>
<td>Flatten into a named list with dot-separated paths</td>
</tr>
<tr>
<td><code>list_find(.x, .p)</code></td>
<td>Find leaves that satisfy a predicate</td>
</tr>
<tr>
<td><code>list_modify_if(.x, .p, .f)</code></td>
<td>Modify leaves that satisfy <code>.p</code> using
<code>.f</code></td>
</tr>
</tbody>
</table>

## Introduction

lstrrr is designed to be a
[purrr](https://github.com/tidyverse/purrr)-like package handling nested
lists. `purrr` also comes with some built-in functions for handling
lists, which can be used alongside `lstrrr` to better serve practical
needs.

## Core Access

`lstrrr` use vector to represent the path to the element,
e.g. `c("a", "b", "c")`, which is similar to the `$` operator in R.

![](do_purrrlike_files/figure-markdown_strict//foo.svg)

    list_get(foo, c("a", "b", "d"))

![](do_purrrlike_files/figure-markdown_strict//list_get.svg)

    list_set(foo, c("a", "b", "d"), TRUE) |> str()

![](do_purrrlike_files/figure-markdown_strict//list_set.svg)

Other functions like `list_delete(x, path)`, `list_has(x, path)`,
`list_depth(x)`, `list_path(x)` are self-explanatory.

## List Conversion

Let’s use the build-in dataset `sputnik_1` as an example:

    list_nleaf(sputnik_1)

![](do_purrrlike_files/figure-markdown_strict//list_nleaf.svg)

You can use `list_flatten()` to flatten a nested list into a flattened
list (the elements of the list are not nested):

    v <- list_flatten(sputnik_1)
    head(v, 3)

![](do_purrrlike_files/figure-markdown_strict//list_flatten.svg)

    cli::cli_alert_info("Class of v: {.cls {class(v)}}")
    cli::cli_alert_info("Length of v: {.val {length(v)}} (using {.fun length})")
    cli::cli_alert_info(
      "Length of v: {.val {list_nleaf(v)}} (using {.fun list_nleaf})"
    )

![](do_purrrlike_files/figure-markdown_strict//list_flatten_info.svg)

The names of the elements are the dot-separated paths to the elements:

    head(names(v))

![](do_purrrlike_files/figure-markdown_strict//list_flatten_names.svg)

Separation symbols can be customized. Generally I don’t recommend using
`_` as purrr does, because it’s a common separator in names.

    v2 <- list_flatten(sputnik_1, "$")
    head(names(v2))

![](do_purrrlike_files/figure-markdown_strict//dollar_sep.svg)

**Recursive mapping is the main difference between
`lstrrr::list_flatten()` and `purrr::list_flatten()`.**, the former will
flatten all levels of the list, while the latter will flatten the second
level of the list (the first level is the list itself).

    v3 <- purrr::list_flatten(sputnik_1, is_node = is.list)
    head(v, 3)

![](do_purrrlike_files/figure-markdown_strict//purrr_list_flatten.svg)

    cli::cli_alert_info("Class of v3: {.cls {class(v3)}}")
    cli::cli_alert_info("Length of v3: {.val {length(v3)}} (using {.fun length})")
    cli::cli_alert_info(
      "Length of v3: {.val {list_nleaf(v3)}} (using {.fun list_nleaf})"
    )

![](do_purrrlike_files/figure-markdown_strict//purrr_list_flatten_info.svg)

## Functional Programming

lstrrr provides a set of functions that are similar to `purrr`’s, but
for handling nested lists. Just use `list_*` as the prefix of the
function name.

    foo <- list(a = 1, b = list(c = "a", d = FALSE))

    list_map(foo, \(x) typeof(x)) |> str()

![](do_purrrlike_files/figure-markdown_strict//list_map.svg)

    list_imap(foo, ~ paste(.y, ":", .x)) |> str()

![](do_purrrlike_files/figure-markdown_strict//list_imap.svg)

If you want to map over multiple lists, make sure the lists have the
same structure.

    list_walk2(foo, foo, ~ message(paste0(.x, .y)))

![](do_purrrlike_files/figure-markdown_strict//list_walk2.svg)

    list_pwalk(
      list(foo, foo, foo),
      \(x, y, z) {
        Sys.sleep(0.5)
      },
      .progress = "pwalk"
    )

![](do_purrrlike_files/figure-markdown_strict//list_pwalk.svg)

Customize the progress bar:

    list_walk(
      sputnik_1,
      ~ Sys.sleep(0.05),
      .progress = list(name = "foo", type = "download")
    )

![](do_purrrlike_files/figure-markdown_strict//list_walk.svg)

`list_find()` is used to find elements that satisfy a predicate. Please
note that the result is a list with only 1 level.

    list_find(foo, ~ is.character(.x)) |> str()

![](do_purrrlike_files/figure-markdown_strict//list_find.svg)

`list_modify_if` is used to modify elements that satisfy a predicate.
The structure of the list is preserved.

    list_modify_if(foo, is.logical, ~ !.x) |> str()

![](do_purrrlike_files/figure-markdown_strict//list_modify_if.svg)
