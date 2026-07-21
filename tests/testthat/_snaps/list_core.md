# list_get errors on invalid path type

    Code
      list_get(x, TRUE)
    Condition
      Error in `list_get()`:
      ! `path` must be character, integer, or numeric.

# list_has errors on invalid path type

    Code
      list_has(x, TRUE)
    Condition
      Error in `list_has()`:
      ! `path` must be character, integer, or numeric.

# list_set errors on invalid path type

    Code
      list_set(x, TRUE, 1)
    Condition
      Error in `list_set()`:
      ! `path` must be character, integer, or numeric.

# list_set with NA integer path errors

    Code
      list_set(y, c(1L, NA_integer_), 1)
    Condition
      Error in `list_set()`:
      ! Invalid numeric path.

# list_set with zero integer path errors

    Code
      list_set(y, c(1L, 0L), 1)
    Condition
      Error in `list_set()`:
      ! Invalid numeric path.

# list_delete errors on invalid path type

    Code
      list_delete(x, TRUE)
    Condition
      Error in `list_delete()`:
      ! `path` must be character, integer, or numeric.

