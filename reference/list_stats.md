# Convert a Nested List to Tree Data

Convert a Nested List to Tree Data

## Usage

``` r
list_stats(x, max_depth = NULL)
```

## Arguments

- x:

  A nested list to traverse.

  Lists are traversed recursively. Non-list objects are treated as
  leaves. Data frames are not traversed and are treated as leaf values.

- max_depth:

  Maximum depth to display.

  A single non-negative integer or `NULL`. If `NULL`, the full nested
  structure is displayed. If supplied, only nodes with depth less than
  or equal to `max_depth` are included. This value is passed directly to
  `list_stats()`.

## Value

A list with two data frames:

- `nodes`: one row per visited node, with columns:

  - `id`: integer node id assigned in traversal order;

  - `parent`: integer id of the parent node, or `NA` for the root;

  - `name`: node name, using positional indices for unnamed elements;

  - `type`: object type. Data frames are labelled `"data.frame"`, lists
    are labelled `"list"`, and other objects use
    [`base::typeof()`](https://rdrr.io/r/base/typeof.html);

  - `path`: dot-separated path from `"root"` to the node;

  - `depth`: integer depth, where the root has depth `0`;

  - `is_leaf`: logical indicating whether the node is not traversed
    further.

- `edges`: one row per parent-child relationship, with columns:

  - `from`: parent node id;

  - `to`: child node id.

If no nodes or edges are produced, empty data frames with the same
column structure are returned.

## See also

[`viz_list()`](https://exceret.github.io/lstrrr/reference/viz_list.md)

Other lstrrr-visualization:
[`viz_list()`](https://exceret.github.io/lstrrr/reference/viz_list.md)

## Examples

``` r
x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  ),
  unnamed = list(5, z = 6),
  df = data.frame(v = 1:2)
)

stats <- list_stats(x)

stats$nodes
#>    id parent    name       type           path depth is_leaf
#> 1   1     NA    root       list           root     0   FALSE
#> 2   2      1       a     double         root.a     1    TRUE
#> 3   3      1       b       list         root.b     1   FALSE
#> 4   4      3       x     double       root.b.x     2    TRUE
#> 5   5      3       y       list       root.b.y     2   FALSE
#> 6   6      5       i     double     root.b.y.i     3    TRUE
#> 7   7      5       j     double     root.b.y.j     3    TRUE
#> 8   8      1 unnamed       list   root.unnamed     1   FALSE
#> 9   9      8       1     double root.unnamed.1     2    TRUE
#> 10 10      8       z     double root.unnamed.z     2    TRUE
#> 11 11      1      df data.frame        root.df     1    TRUE
stats$edges
#>    from to
#> 1     1  2
#> 2     1  3
#> 3     3  4
#> 4     3  5
#> 5     5  6
#> 6     5  7
#> 7     1  8
#> 8     8  9
#> 9     8 10
#> 10    1 11

# Limit traversal depth
list_stats(x, max_depth = 1)
#> $nodes
#>   id parent    name       type         path depth is_leaf
#> 1  1     NA    root       list         root     0   FALSE
#> 2  2      1       a     double       root.a     1    TRUE
#> 3  3      1       b       list       root.b     1   FALSE
#> 4  4      1 unnamed       list root.unnamed     1   FALSE
#> 5  5      1      df data.frame      root.df     1    TRUE
#> 
#> $edges
#>   from to
#> 1    1  2
#> 2    1  3
#> 3    1  4
#> 4    1  5
#> 

# Unnamed elements use their position as the node name
list_stats(list(10, a = list(20)))$nodes
#>   id parent name   type     path depth is_leaf
#> 1  1     NA root   list     root     0   FALSE
#> 2  2      1    1 double   root.1     1    TRUE
#> 3  3      1    a   list   root.a     1   FALSE
#> 4  4      3    1 double root.a.1     2    TRUE
```
