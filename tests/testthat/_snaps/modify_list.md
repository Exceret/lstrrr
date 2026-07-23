# keep.null must be TRUE or FALSE (length-1 logical)

    Code
      modify_list(list(a = 1), list(b = 2), keep.null = "yes")
    Condition
      Error in `modify_list()`:
      ! `keep.null` must be TRUE or FALSE.

---

    Code
      modify_list(list(a = 1), list(b = 2), keep.null = c(TRUE, FALSE))
    Condition
      Error in `modify_list()`:
      ! `keep.null` must be TRUE or FALSE.

# keep.null must not be NA

    Code
      modify_list(list(a = 1), list(b = 2), keep.null = NA)
    Condition
      Error in `modify_list()`:
      ! `keep.null` must not be NA.

# x must be a list (not a data.frame)

    Code
      modify_list(data.frame(a = 1), list(b = 2))
    Condition
      Error in `modify_list()`:
      ! `x` must be a list.

# x must be a list (not an atomic vector)

    Code
      modify_list(c(a = 1), list(b = 2))
    Condition
      Error in `modify_list()`:
      ! `x` must be a list.

# val must be a list

    Code
      modify_list(list(a = 1), c(b = 2))
    Condition
      Error in `modify_list()`:
      ! `val` must be a list.

---

    Code
      modify_list(list(a = 1), data.frame(b = 2))
    Condition
      Error in `modify_list()`:
      ! `val` must be a list.

