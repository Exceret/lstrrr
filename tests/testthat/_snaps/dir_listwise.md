# dir_listwise errors on non-character paths

    Code
      dir_listwise(1:5)
    Condition
      Error:
      ! `paths` must be a character vector.

# dir_listwise errors on invalid value

    Code
      dir_listwise("a.R", value = "invalid")
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of "path", "name", "TRUE"

