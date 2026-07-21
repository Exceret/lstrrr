# list_modify_if errors on two-sided formula for .p

    Code
      list_modify_if(x, .p = y ~ x + 1, .f = identity)
    Condition
      Error:
      x Formula must be one-sided, e.g. `~ .x + 1`.

# list_modify_if errors on two-sided formula for .f

    Code
      list_modify_if(x, .p = is.numeric, .f = y ~ x + 1)
    Condition
      Error:
      x Formula must be one-sided, e.g. `~ .x + 1`.

# list_modify_if errors on non-coercible .p

    Code
      list_modify_if(x, .p = "not_a_function", .f = identity)
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

# list_modify_if errors on non-coercible .f

    Code
      list_modify_if(x, .p = is.numeric, .f = "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

