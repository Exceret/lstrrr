# Visualize Nested List Structure

Creates a tree-style visualization of the structure of a nested list
using ggplot2.

## Usage

``` r
viz_list(
  x,
  max_depth = NULL,
  show_path = FALSE,
  point_size = 3L,
  text_size = 3L,
  line_width = 0.6,
  flip = FALSE
)
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
  [`list_stats()`](https://exceret.github.io/lstrrr/reference/list_stats.md).

- show_path:

  Logical scalar.

  If `FALSE`, node labels show the node's own name and type. If `TRUE`,
  node labels show the full path and type.

- point_size:

  Numeric scalar giving the size of node points passed to
  [`ggplot2::geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html).

- text_size:

  Numeric scalar giving the size of node labels passed to
  [`ggplot2::geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html).

- line_width:

  Numeric scalar giving the width of edges passed to
  [`ggplot2::geom_segment()`](https://ggplot2.tidyverse.org/reference/geom_segment.html).

- flip:

  Logical scalar.

  If `TRUE`, the coordinate system is flipped so that the tree is drawn
  horizontally (depth on the x-axis) instead of vertically (depth on the
  y-axis). This is equivalent to calling
  [`ggplot2::coord_flip()`](https://ggplot2.tidyverse.org/reference/coord_flip.html).

## Value

A [ggplot2::ggplot](https://ggplot2.tidyverse.org/reference/ggplot.html)
object representing the nested list as a tree diagram.

The plot contains:

- line segments for parent-child edges;

- points for nodes, colored by node type;

- text labels showing either node names or full paths plus node types;

- a y-axis labelled by list depth.

## See also

[`list_stats()`](https://exceret.github.io/lstrrr/reference/list_stats.md)

Other lstrrr-visualization:
[`list_stats()`](https://exceret.github.io/lstrrr/reference/list_stats.md)

## Examples

``` r
if (FALSE) { # \dontrun{
x <- list(
  a = 1,
  b = list(
    x = 2,
    y = list(i = 3, j = 4)
  ),
  c = data.frame(z = 1:3)
)

# Visualize the full structure
viz_list(x)

# Show full paths in node labels
viz_list(x, show_path = TRUE)

# Limit the displayed depth
viz_list(x, max_depth = 1)

# Customize appearance
viz_list(
  x,
  point_size = 4,
  text_size = 3.5,
  line_width = 1
)

# Flip coordinates for horizontal layout
viz_list(x, flip = TRUE)
} # }
```
