# list_filter errors on two-sided formula for .p

    Code
      list_filter(x, y ~ x + 1)
    Condition
      Error:
      x Formula must be one-sided, e.g. `~ .x + 1`.

# list_filter errors on non-coercible .p

    Code
      list_filter(x, "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

