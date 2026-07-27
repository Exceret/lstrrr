# lstrrr 0.1.0 (2026-07-21)

## TESTING

* Incorporate tests for all functions


## DOCUMENTATION

* Updated documentation for all functions, including code examples and parameters descriptions


## NEW FEATURES

* Added `dir_listwise()`, which makes output of `list.files()` into a nested list
* Added `list_find_value()`, which finds all paths in a nested list whose element is identical to a given value.
* `list_map()`, `list_map2()`, `list_imap()`, and `list_pmap()` now support a `.progress` argument to show a progress bar during traversal.
* `list_map()`, `list_map2()`, and `list_imap()` now use `.x` as the first argument (renamed from `x`) for consistency with purrr naming conventions.


# lstrrr 0.0.0.9000 (2026-07-20)

## NEW FEATURES

* Init Version
  * purrr-like function to process nested list
  * `viz_list()`: A funtion to visualize the structure of a nested list
  * `modify_list()`: A function to modify list with another one
