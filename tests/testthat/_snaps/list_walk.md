# list_walk errors on two-sided formula

    Code
      list_walk(x, y ~ x + 1)
    Condition
      Error:
      x Formula must be one-sided, e.g. `~ .x + 1`.

# list_walk errors on non-coercible .f

    Code
      list_walk(x, "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

# list_walk2 errors on two-sided formula

    Code
      list_walk2(x, x, y ~ x + 1)
    Condition
      Error:
      x Formula must be one-sided, e.g. `~ .x + 1`.

# list_walk2 errors on non-coercible .f

    Code
      list_walk2(x, x, "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

# list_pwalk on empty .l errors

    Code
      list_pwalk(list(), function(...) NULL)
    Condition
      Warning in `max()`:
      no non-missing arguments to max; returning -Inf
      Error in `seq_len()`:
      ! argument must be coercible to non-negative integer

# list_pwalk errors when .l is not a list

    Code
      list_pwalk("not_a_list", identity)
    Condition
      Error:
      x `.l` must be a <list>.

# list_pwalk errors on two-sided formula

    Code
      list_pwalk(list(x), y ~ x + 1)
    Condition
      Error:
      x Formula must be one-sided, e.g. `~ .x + 1`.

# list_pwalk errors on non-coercible .f

    Code
      list_pwalk(list(x), "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

