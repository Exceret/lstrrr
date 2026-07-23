# list_walk errors on non-coercible .f

    Code
      list_walk(x, "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

# list_walk2 errors on non-coercible .f

    Code
      list_walk2(x, x, "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

# list_pwalk errors on non-coercible .f

    Code
      list_pwalk(list(x), "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

# list_iwalk errors on non-coercible .f

    Code
      list_iwalk(x, "not_a_function")
    Condition
      Error in `get()`:
      ! object 'not_a_function' of mode 'function' was not found

