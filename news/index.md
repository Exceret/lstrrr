# Changelog

## lstrrr 0.1.0 (2026-07-21)

### TESTING

- Incorporate tests for all functions

### DOCUMENTATION

- Updated documentation for all functions, including code examples and
  parameters descriptions

### NEW FEATURES

- Added
  [`dir_listwise()`](https://exceret.github.io/lstrrr/reference/dir_listwise.md),
  which makes output of
  [`list.files()`](https://rdrr.io/r/base/list.files.html) into a nested
  list
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
