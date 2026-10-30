---
name: lstrrr
description: Work with complex, deeply nested R lists using the lstrrr package — path-based read/write/delete/rename, recursive map/walk/filter/modify_if, flatten, tree statistics, and ggplot2 tree visualization. This skill should be used whenever a task touches a nested R list (JSON/API payload, YAML config, nested model output, package metadata, directory tree) and requires reading a value by path, recursing over leaves, transforming or filtering leaves in place, merging two nested lists, or inspecting/plotting the structure. Triggers on nested list, deeply nested list, recursive list traversal, list_map, list_get, list_set, list_flatten, list_stats, viz_list, modify_list, dir_listwise.
---

# lstrrr — functional tools for deeply nested R lists

`lstrrr` treats a list as a tree and applies functions to **leaf nodes**, always
returning the **same nested structure**. `purrr` and `base::rapply()` collapse
the result to a vector or a flat list; `lstrrr` never does.

## When to use

Use `lstrrr` only for **complex nested lists** — a list that contains other
lists. Anything shallower is better served by `purrr` or `base::lapply()`.

## Step 0 — Verify the object is a complex nested list (mandatory)

Do this **before** choosing any `lstrrr` function. An object is a *complex
nested list* when it is a list (not a data frame) **and** its depth is at least
2, i.e. at least one list is nested inside another list.

Run the bundled checker when the object already exists in a file, an RDS, or can
be produced by an expression:

```bash
Rscript scripts/detect_nested.R object.rds
Rscript scripts/detect_nested.R --expr "jsonlite::fromJSON('payload.json')"
Rscript scripts/detect_nested.R --file analysis.R --object cfg
```

It prints `depth`, `n_leaf`, `n_node`, `leaf_types`, whether the list has
unnamed elements / `NULL` leaves / empty lists, sample leaf paths, and a final
`verdict:` line of either `COMPLEX_NESTED_LIST` or `NOT_COMPLEX_NESTED_LIST`.

Without the script, evaluate the same check inline:

```r
is_node <- function(x) is.list(x) && !is.data.frame(x)
depth_of <- function(x) {
  if (!is_node(x)) return(0L)
  if (length(x) == 0L) return(1L)
  1L + max(vapply(x, depth_of, integer(1L)))
}
is_node(x) && depth_of(x) >= 2L
```

If the check fails — the object is an atomic vector, a data frame, a flat list
of leaves, or a list whose depth is 1 — **stop and tell the user to use `purrr`
or `base::lapply()` instead**:

| Object shape | Recommended tool |
| --- | --- |
| atomic vector, data frame, matrix | `vapply()` / `dplyr` / vectorised code |
| flat named list of leaves (`depth == 1`) | `purrr::map()`, `purrr::imap()`, `base::lapply()` |
| flat list needing a data frame out | `purrr::map_dfr()`, `purrr::list_rbind()` |
| `depth >= 2` nested list | `lstrrr` (this skill) |

Report what was measured (e.g. "depth is 1, so this is a flat list — use
`purrr::map()`") rather than silently proceeding with `lstrrr`.

## Core model — read before picking a function

- **Leaf** = any non-list object. A **data frame is a leaf and is never
  traversed**, even though `is.data.frame()` implies `is.list()`.
- **Path** = a character vector of names, or an integer vector of **one-based**
  positions. `c("b", "y", "i")` means `x[["b"]][["y"]][["i"]]`. Unnamed
  elements are addressed by position and named by position in results.
- **Empty path** (`character(0)`) refers to the root object itself.
- Every function returns a **modified copy**; the input is never mutated in
  place. Always reassign: `x <- list_set(x, path, value)`.
- `.f` / `.p` accept a function, a **one-sided** formula (`~ .x > 2`), or
  anything `match.fun()` resolves (`is.numeric`, `toupper`). Extra `...`
  arguments are forwarded to `.f`.
- Predicates keep a leaf only when the result is exactly `TRUE`
  (`isTRUE()`); `NA` and other values drop the leaf.
- `.progress = TRUE` renders a `cli` progress bar; a string names it; a list
  configures it (`?cli::cli_progress_bar`).

## Step 1 — Route by task

| Task | Function |
| --- | --- |
| Read the value at a path (with fallback) | `list_get(x, path, default = NULL)` |
| Test whether a path exists | `list_has(x, path)` |
| Write or replace the value at a path | `list_set(x, path, value)` |
| Remove the node at a path | `list_delete(x, path)` |
| Rename the node at a path | `list_rename(x, path, name)` |
| Measure depth / count leaves | `list_depth(x)` / `list_nleaf(x)` |
| Enumerate every leaf path | `list_path(x)` |
| Find paths holding an identical value | `list_find_value(x, value)` |
| Transform every leaf, keep structure | `list_map(.x, .f, ...)` |
| Transform leaves of two lists in lockstep | `list_map2(.x, .y, .f, ...)` |
| Transform leaves of many lists in lockstep | `list_pmap(.l, .f, ...)` |
| Transform leaves and need the name or path | `list_imap(.x, .f, .name = "name" \| "path")` |
| Side effects only (print, save, write) | `list_walk()` / `list_walk2()` / `list_pwalk()` / `list_iwalk()` |
| Collect matching leaves into a **flat** list | `list_find(.x, .p)` |
| Collapse the whole tree to a flat named list | `list_flatten(.x, .sep = ".")` |
| Keep structure, blank out non-matching leaves | `list_filter(.x, .p)` |
| Transform **only** leaves matching a predicate | `list_modify_if(.x, .p, .f, ...)` |
| Patch/merge one nested list with another | `modify_list(x, val, keep.null = FALSE)` |
| Get the tree as `nodes` / `edges` data frames | `list_stats(x, max_depth = NULL)` |
| Draw the tree with ggplot2 | `viz_list(x, ...)` |
| Build a nested list from file paths | `dir_listwise(paths, value = "path")` |

Two decisions that are easy to get wrong:

- **Flat result or structured result?** `list_find()` returns a *flat* list
  named by dotted path. `list_filter()` returns the *original structure* with
  non-matching leaves replaced by `NULL`.
- **All leaves or some leaves?** `list_map()` hits every leaf.
  `list_modify_if()` hits only leaves satisfying `.p`, leaving the rest
  untouched (no `NULL` placeholders).

## Step 2 — Write the code

```r
library(lstrrr)

x <- list(a = 1, b = list(x = 2, y = list(i = 3, j = 4)))

list_get(x, c("b", "y", "i"))                 # 3
list_set(x, c("b", "y", "i"), 300)            # copy with one leaf changed
list_flatten(x)                               # a=1 b.x=2 b.y.i=3 b.y.j=4
list_map(x, ~ .x * 2)                         # same shape, every leaf doubled
list_modify_if(x, ~ is.numeric(.x) && .x > 2, ~ .x * 10)
list_find(x, ~ .x > 2)                        # flat: $b.y.i, $b.y.j
list_imap(x, \(v, p) paste(p, collapse = "/"), .name = "path")
```

Loop over all leaves without hand-rolling recursion:

```r
paths <- list_path(x)
lapply(paths, \(p) list_get(x, p))
```

## Pitfalls

- `list_map2()` / `list_pmap()` align by **structure and position**; a missing
  counterpart arrives as `NULL`, so guard `.f` against `NULL` inputs.
- Integer paths are one-based. `list_get(x, c(2L, 2L, 2L))` is not zero-based.
- `list_filter()` leaves `NULL` holes in the tree; it does not shorten it.
- `NULL` is a valid leaf for `lstrrr` and is preserved by `list_flatten()`,
  which differs from base R where `x$b <- NULL` deletes the element.
- Data frames, environments, and other non-list objects are leaves — never
  assume a `data.frame` is recursed into.
- `viz_list()` requires `ggplot2` and calls `rlang::check_installed()`.
- `list_stats()` names the root `"root"` with `depth = 0`; `viz_list()` plots
  `-depth` on the y axis.

## Bundled resources

- `scripts/detect_nested.R` — the Step 0 structural check, runnable without
  `lstrrr` installed.
- `references/api_reference.md` — signatures, arguments, return values, and
  examples for all 21 exported functions.
- `references/recipes.md` — end-to-end solutions for recurring nested-list
  tasks.
