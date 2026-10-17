# Changelog

## lstrrr 0.1.2 (2026-10-17)

### NEW FEATURES

- Added
  [`list_rename()`](https://exceret.github.io/lstrrr/reference/list_rename.md),
  which renames the last slot of a path in a nested list while keeping
  the elements untouched and shared with the original object.

## lstrrr 0.1.1 (2026-08-30)

### NEW FEATURES

- Added
  [`list_filter()`](https://exceret.github.io/lstrrr/reference/list_filter.md),
  which keeps leaves satisfying a predicate and replaces the others with
  `NULL`, preserving the original nested structure.

### TESTING

- Added comprehensive tests for
  [`list_filter()`](https://exceret.github.io/lstrrr/reference/list_filter.md),
  covering predicate matching, structure preservation,
  [`isTRUE()`](https://rdrr.io/r/base/Logic.html) semantics, edge cases,
  and error handling.
- Incorporated benchmark tests between lstrrr and rrapply.

### DOCUMENTATION

- Added
  [`list_filter()`](https://exceret.github.io/lstrrr/reference/list_filter.md)
  with an example to the `do_purrrlike` vignette.

## lstrrr 0.1.0 (2026-07-21)

### TESTING

- Incorporate tests for all functions
- Added tests for
  [`list_find_value()`](https://exceret.github.io/lstrrr/reference/list_find_value.md)
  and
  [`list_nleaf()`](https://exceret.github.io/lstrrr/reference/list_nleaf.md)

### DOCUMENTATION

- Updated documentation for all functions, including code examples and
  parameters descriptions
- Added
  [`list_find_value()`](https://exceret.github.io/lstrrr/reference/list_find_value.md)
  with an example to the `do_purrrlike` vignette
- Updated the pkgdown reference index (`_pkgdown.yml`) to include
  [`list_find_value()`](https://exceret.github.io/lstrrr/reference/list_find_value.md)

### NEW FEATURES

- Added
  [`dir_listwise()`](https://exceret.github.io/lstrrr/reference/dir_listwise.md),
  which makes output of
  [`list.files()`](https://rdrr.io/r/base/list.files.html) into a nested
  list
- Added
  [`list_find_value()`](https://exceret.github.io/lstrrr/reference/list_find_value.md),
  which finds all paths in a nested list whose element is identical to a
  given value.
- [`list_map()`](https://exceret.github.io/lstrrr/reference/list_map.md),
  [`list_map2()`](https://exceret.github.io/lstrrr/reference/list_map2.md),
  [`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md),
  and
  [`list_pmap()`](https://exceret.github.io/lstrrr/reference/list_pmap.md)
  now support a `.progress` argument to show a progress bar during
  traversal.
- [`list_map()`](https://exceret.github.io/lstrrr/reference/list_map.md),
  [`list_map2()`](https://exceret.github.io/lstrrr/reference/list_map2.md),
  and
  [`list_imap()`](https://exceret.github.io/lstrrr/reference/list_imap.md)
  now use `.x` as the first argument (renamed from `x`) for consistency
  with purrr naming conventions.

## lstrrr 0.0.0.9000 (2026-07-20)

### NEW FEATURES

- Init Version
  - purrr-like function to process nested list
  - [`viz_list()`](https://exceret.github.io/lstrrr/reference/viz_list.md):
    A funtion to visualize the structure of a nested list
  - [`modify_list()`](https://exceret.github.io/lstrrr/reference/modify_list.md):
    A function to modify list with another one
