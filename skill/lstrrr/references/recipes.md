# lstrrr recipes

End-to-end solutions for recurring nested-list tasks. Always run the Step 0
check in `SKILL.md` before applying them.

## Inspect an unknown payload

```r
list_depth(obj)
list_nleaf(obj)
list_stats(obj)$nodes          # one row per node: id, parent, name, type, path, depth, is_leaf
viz_list(obj, max_depth = 3)   # needs ggplot2
list_path(obj) |> head(20L)    # sample leaf paths
```

## Tabulate every leaf as a data frame

```r
flat <- list_flatten(obj)
data.frame(
  path  = names(flat),
  type  = vapply(flat, \(z) if (is.null(z)) "NULL" else class(z)[[1]], character(1)),
  depth = lengths(strsplit(names(flat), ".", fixed = TRUE))
)
```

## Read a value safely with a fallback

```r
if (list_has(obj, c("response", "body", "id"))) {
  list_get(obj, c("response", "body", "id"))
} else {
  list_get(obj, c("response", "body", "id"), default = NA_character_)
}
```

## Patch a deeply nested value

```r
obj <- list_set(obj, c("config", "database", "port"), 5432L)
```

When several keys change at once, patch with a nested `val` list instead:

```r
obj <- modify_list(obj, list(config = list(database = list(port = 5432L, ssl = TRUE))))
# keep.null = TRUE keeps NULL entries, FALSE removes the matching component
```

## Remove and rename keys by path

```r
obj <- list_delete(obj, c("credentials", "password"))
obj <- list_rename(obj, c("user", "usr_name"), "user_name")
```

## Recursively transform leaves

```r
# every leaf
list_map(obj, ~ .x)

# only numeric leaves, others untouched
list_modify_if(obj, is.numeric, ~ round(.x, 2))

# leaves that need their own path
list_imap(obj, \(v, p) paste(p, collapse = "/"), .name = "path")

# long recursion: show a cli progress bar
list_map(obj, slow_fun, .progress = "Transforming leaves")
```

## Recurse for side effects

```r
list_walk(obj, \(v) cat(format(v), "\n"))
list_iwalk(obj, \(v, p) saveRDS(v, paste0(p, collapse = "_"), ".rds"), .name = "path")
```

## Find and extract matching leaves

```r
list_find(obj, ~ is.character(.x) && grepl("error", .x, ignore.case = TRUE))
list_find_value(obj, "pending")            # paths whose value is identical
```

## Diff two versions of the same structure

```r
a <- list_flatten(old)
b <- list_flatten(new)

added   <- setdiff(names(b), names(a))
removed <- setdiff(names(a), names(b))
common  <- intersect(names(a), names(b))
changed <- common[!mapply(identical, a[common], b[common])]
```

## Prune a tree

```r
# keep the shape, blank out what is not needed
list_filter(obj, ~ !is.null(.x))

# drop empty branches after filtering is not automatic —
# build the pruned result explicitly from the kept paths
keep <- list_find(obj, ~ !is.null(.x))
out <- list()
for (nm in names(keep)) out <- list_set(out, strsplit(nm, ".", fixed = TRUE)[[1]], keep[[nm]])
```

## Turn a directory listing into a nested list

```r
paths <- list.files("project", recursive = TRUE)
tree  <- dir_listwise(paths)               # leaves hold the full path
names_only <- dir_listwise(paths, value = "name")
structure_only <- dir_listwise(paths, value = "TRUE")
```

## Compare against base R / purrr

`base::rapply()` and `rrapply::rrapply()` also recurse, but `lstrrr`
additionally offers path-based accessors (`list_get()`, `list_set()`,
`list_has()`), a `cli` progress bar, and structure-preserving helpers
(`list_filter()`, `list_modify_if()`). `purrr::map()` operates on the top level
only and collapses results; use it for flat lists, `lstrrr` for nested ones.
