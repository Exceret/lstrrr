# lstrrr API reference

Complete reference for the 21 exported functions of `lstrrr` (version 0.1.2)
plus the bundled example dataset.

Install / load:

```r
pak::pak("Exceret/lstrrr")
library(lstrrr)
```

Running example used throughout:

```r
x <- list(
  a = 1,
  b = list(x = 2, y = list(i = 3, j = 4)),
  unnamed = list(5, z = 6),
  df = data.frame(v = 1:3)
)
```

## Shared conventions

- `x` / `.x` — the nested list. Lists are traversed recursively; non-list
  objects are leaves. **Data frames are leaves and are not traversed.**
- `path` — character vector of names or integer vector of one-based positions.
  `character(0)` refers to `x` itself.
- `.f` — a function, a one-sided formula (`~ .x + 1`), or anything
  `match.fun()` resolves. Two-sided formulas are rejected
  (`~` must be one-sided).
- `.p` — a predicate following the same rules; a leaf is kept only when the
  predicate returns exactly `TRUE`.
- `...` — extra arguments forwarded to `.f`.
- `.progress` — `FALSE` (default), `TRUE`, a name string, or a `cli` progress
  bar configuration list.
- Nothing is modified in place; always reassign the result.

---

## 1. Core accessors (`lstrrr_core`)

### `list_get(x, path, default = NULL)`

Value stored at `path`, or `default` when the path is missing or cannot be
traversed.

```r
list_get(x, c("b", "y", "i"))          # 3
list_get(x, c(2L, 2L, 2L))             # 4 — integer path, one-based
list_get(x, c("b", "missing"), default = NA)
list_get(x, character(0))              # x itself
list_get(x, "df")                      # the whole data frame
list_get(x, c("df", "v"), default = "not traversed")
```

### `list_has(x, path)`

Logical scalar: `TRUE` when `path` exists. Empty path is always `TRUE`.
Prefer this over `is.null(list_get(...))` when `NULL` is a legitimate value.

```r
list_has(x, c("b", "y", "i"))  # TRUE
list_has(x, c("df", "v"))      # FALSE — data frames are not traversed
```

### `list_set(x, path, value)`

Copy of `x` with `value` assigned at `path`. Intermediate levels must exist.

```r
list_set(x, c("b", "y", "i"), 100)
list_set(x, character(0), "replacement")  # replaces everything
```

### `list_delete(x, path)`

Copy of `x` with the element at `path` removed.

```r
list_delete(x, c("b", "y", "j"))
```

### `list_rename(x, path, name)`

Copy of `x` with the **last** slot of `path` renamed. Only names change; the
elements themselves are shared with the original. Missing paths or a non-list
parent return `x` unchanged.

```r
list_rename(x, c("b", "y", "i"), "renamed")
```

### `list_depth(x)`

Integer maximum depth. A non-list leaf is `0`; a list of leaves is `1`;
each further nesting level adds 1. Data frames count as leaves.

```r
list_depth(x)               # 3
list_depth(list(a = 1))     # 1
list_depth(1)               # 0
```

### `list_nleaf(x)`

Number of leaf nodes. Integer when possible, double for very large counts.

```r
list_nleaf(x)
list_nleaf(list())
```

### `list_path(x)`

List of character vectors, one per leaf — the path to each leaf. Unnamed
elements are labelled by their position. Data frames are single leaves.

```r
paths <- list_path(x)
lapply(paths, \(p) list_get(x, p))
list_path(list(10, list(20, z = 30)))  # "1", "2.z"
```

### `list_find_value(x, value)`

All paths whose element is **identical** to `value`. Returns `NULL` when
nothing matches.

```r
list_find_value(list(a = 1, b = list(c = 2, d = list(e = 1))), 1)
# [[1]] "a"        [[2]] "b" "d" "e"
```

---

## 2. purrr-like recursion (`lstrrr-purrrlike`)

All of these keep the nested structure of `.x`.

### `list_map(.x, .f, ..., .progress = FALSE)`

Replace every leaf with `.f(leaf, ...)`.

```r
list_map(x, ~ .x * 2)
list_map(x, \(v, k) v + k, k = 10, .progress = TRUE)
```

### `list_map2(.x, .y, .f, ..., .progress = FALSE)`

Same, over two lists with matching structure. Missing counterparts arrive as
`NULL`, so `.f` must tolerate `NULL`.

```r
list_map2(x, x, ~ .x + .y)
```

### `list_pmap(.l, .f, ..., .progress = FALSE)`

Same, over a list of nested lists. `.l` must be a list; otherwise a `cli`
error is raised.

```r
list_pmap(list(x, x, x), \(a, b, c) (a + b) * c)
```

### `list_imap(.x, .f, ..., .name = c("name", "path"), .progress = FALSE)`

Like `list_map()`, but `.f` receives a second identifier argument:

- `.name = "name"` — the leaf's own name or positional index (default);
- `.name = "path"` — the full character path from the root.

```r
list_imap(x, \(value, name) paste(name, value, sep = " = "))
list_imap(x, \(value, path) paste(path, collapse = "."), .name = "path")
```

### `list_walk(.x, .f, ..., .progress = FALSE)`
### `list_walk2(.x, .y, .f, ..., .progress = FALSE)`
### `list_pwalk(.l, .f, ..., .progress = FALSE)`
### `list_iwalk(.x, .f, ..., .progress = FALSE)`

Side-effect counterparts of `list_map()`, `list_map2()`, `list_pmap()` and
`list_imap()`. Each invisibly returns the first input (`.x` or `.l`).
`list_iwalk()` forwards `.name` through `...`.

```r
list_walk(x, \(v) cat(v, "\n"))
```

### `list_flatten(.x, .sep = ".")`

Flat named list of all leaves, names being the path joined by `.sep`.
Unnamed elements use their position; empty-string names fall back to the
position. `NULL` leaves are preserved. A non-list input becomes a
single-element list named `""`.

```r
list_flatten(x)          # a, b.x, b.y.i, b.y.j, unnamed.1, unnamed.z, df
list_flatten(x, .sep = "/")
```

### `list_find(.x, .p)`

Flat list of the leaves satisfying `.p`, named by dotted path. Built on
`list_flatten()`, so the same naming rules apply. **No `...` and no
`.progress`.**

```r
list_find(x, ~ is.numeric(.x) && .x > 2)   # $b.y.i, $b.y.j
```

### `list_filter(.x, .p, .progress = FALSE)`

Same structure as `.x`, leaves failing `.p` replaced by `NULL`. Use it when
the shape must be preserved; use `list_find()` for a compact flat result.

```r
list_filter(x, ~ is.numeric(.x) && .x > 2)
```

### `list_modify_if(.x, .p, .f, ...)`

Same structure as `.x`, with only the leaves satisfying `.p` replaced by
`.f(leaf, ...)`. Leaves failing `.p` stay untouched (**no `NULL` holes**,
unlike `list_filter()`). No `.progress` argument.

```r
list_modify_if(x, is.character, toupper)
list_modify_if(x, is.numeric, \(v, inc) v + inc, inc = 10)
list_modify_if(x, is.data.frame, \(d) transform(d, w = v * 2))
```

### Choosing between the three

| Goal | Function | Result shape |
| --- | --- | --- |
| only some leaves, flat, path-named | `list_find()` | flat list |
| only some leaves, keep the tree | `list_filter()` | tree with `NULL` holes |
| only some leaves, transform them | `list_modify_if()` | tree, other leaves intact |
| every leaf, transform them | `list_map()` | tree, all leaves replaced |

---

## 3. Merging

### `modify_list(x, val, keep.null = FALSE)`

Faster, recursion-friendly `utils::modifyList()`. `val` is a named list whose
components patch `x` recursively. `keep.null = TRUE` keeps `NULL` values in
`val`; `FALSE` (default) removes the corresponding components from `x`.

```r
modify_list(
  list(a = 1, b = list(x = 1, y = list(i = 1, j = 2))),
  list(b = list(y = list(j = 99, k = 100)), c = 3)
)
```

---

## 4. Structure inspection and visualization (`lstrrr-visualization`)

### `list_stats(x, max_depth = NULL)`

Returns `list(nodes, edges)`.

- `nodes` — one row per visited node: `id`, `parent` (`NA` for the root),
  `name`, `type` (`"data.frame"`, `"list"`, or `typeof()`), `path`
  (dot-separated from `"root"`), `depth` (root is `0`), `is_leaf`.
- `edges` — one row per parent-child pair: `from`, `to`.

When `max_depth` is supplied, nodes deeper than that are dropped. Empty inputs
return empty data frames with the same columns.

```r
stats <- list_stats(x)
stats$nodes
stats$edges
list_stats(x, max_depth = 1)
```

### `viz_list(x, max_depth = NULL, show_path = FALSE, point_size = 3L, text_size = 3L, line_width = 0.6, flip = FALSE)`

ggplot2 tree diagram of the structure. Requires `ggplot2`
(`rlang::check_installed()`). Returns a `ggplot` object, so layers, themes and
`ggsave()` work as usual.

- `max_depth` — forwarded to `list_stats()`; limits displayed depth.
- `show_path` — label nodes with the full path instead of the node name.
- `flip` — horizontal layout (depth on the x axis).
- y axis is labelled with absolute depth.

```r
viz_list(x)
viz_list(x, show_path = TRUE, flip = TRUE)
viz_list(x, max_depth = 1, point_size = 4, text_size = 3.5, line_width = 1)
```

---

## 5. Building nested lists

### `dir_listwise(paths, value = c("path", "name", "TRUE"), sep = "[/\\\\]+", simplify_empty = TRUE)`

Turns a character vector of file paths (typically `list.files()` output) into a
nested named list mirroring the directory tree. `paths` must be a character
vector, otherwise a `cli` error is raised; `NA` entries are dropped.

- `value = "path"` — leaf holds the full path (default);
- `value = "name"` — leaf holds the basename;
- `value = "TRUE"` — leaf holds `TRUE` (pure structure).

```r
paths <- c("R/list-core.R", "R/viz-list.R", "src/init.c", "DESCRIPTION")
dir_listwise(paths)
dir_listwise(paths, value = "name")
```

---

## 6. Bundled dataset

### `sputnik_1`

A large nested list describing Sputnik 1, useful for exercising recursion:
deep nesting, named and unnamed branches, `NULL` leaves, empty lists, `Date`
and `POSIXct` objects, character/numeric vectors, and data frames that must be
treated as leaves.

```r
data(sputnik_1)
list_depth(sputnik_1)
list_nleaf(sputnik_1)
list_imap(sputnik_1, \(v, p) paste(p, collapse = "."), .name = "path")
```
