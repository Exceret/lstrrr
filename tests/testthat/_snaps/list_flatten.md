# list_flatten errors on non-string sep

    Code
      list_flatten(x, sep = 1)
    Condition
      Error in `list_flatten()`:
      ! `sep` must be a string.

# list_flatten errors on sep of length > 1

    Code
      list_flatten(x, sep = c(".", "-"))
    Condition
      Error in `list_flatten()`:
      ! `sep` must be a string.

# list_find errors on two-sided formula

    Code
      list_find(x, y ~ x + 1)
    Condition
      Error:
      x Formula must be one-sided, e.g. `~ .x + 1`.

# list_find errors when .p is not coercible to function

    Code
      list_find(x, "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

