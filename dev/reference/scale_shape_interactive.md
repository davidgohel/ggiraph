# Create interactive scales for shapes

These scales are based on
[`ggplot2::scale_shape()`](https://ggplot2.tidyverse.org/reference/scale_shape.html),
[`ggplot2::scale_shape_continuous()`](https://ggplot2.tidyverse.org/reference/scale_shape.html),
[`ggplot2::scale_shape_discrete()`](https://ggplot2.tidyverse.org/reference/scale_shape.html),
[`ggplot2::scale_shape_binned()`](https://ggplot2.tidyverse.org/reference/scale_shape.html)
and
[`ggplot2::scale_shape_ordinal()`](https://ggplot2.tidyverse.org/reference/scale_shape.html).
See the documentation for those functions for more details.

## Usage

``` r
scale_shape_interactive(...)

scale_shape_continuous_interactive(...)

scale_shape_discrete_interactive(...)

scale_shape_binned_interactive(...)

scale_shape_ordinal_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/dev/reference/interactive_parameters.md).

## Value

An interactive scale object.

## Details for interactive scale and interactive guide functions

For scales, the interactive parameters can be supplied as arguments in
the relevant function and they can be scalar values or vectors,
depending on the number of breaks (levels) and the type of the guide
used. The guides do not accept any interactive parameter directly, they
receive them from the scales.

When guide of type `legend`, `bins`, `colourbar` or `coloursteps` is
used, it will be converted to a
[`guide_legend_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/guide_legend_interactive.md),
[`guide_bins_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/guide_bins_interactive.md),
[`guide_colourbar_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/guide_colourbar_interactive.md)
or
[`guide_coloursteps_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/guide_coloursteps_interactive.md)
respectively, if it's not already.

The length of each scale interactive parameter vector should match the
length of the breaks. It can also be a named vector, where each name
should correspond to the same break name. It can also be defined as
function that takes the breaks as input and returns a named or unnamed
vector of values as output.

For binned guides like `bins` and `coloursteps` the breaks include the
label breaks and the limits. The number of bins will be one less than
the number of breaks and the interactive parameters can be constructed
for each bin separately (look at the examples). For `colourbar` guide in
raster mode, the breaks vector, is scalar 1 always, meaning the
interactive parameters should be scalar too. For `colourbar` guide in
non-raster mode, the bar is drawn using rectangles, and the breaks are
the midpoints of each rectangle.

The interactive parameters here, give interactivity only to the key
elements of the guide.

To provide interactivity to the rest of the elements of a guide, (title,
labels, background, etc), the relevant theme elements or relevant guide
arguments can be used. The `guide` arguments `title.theme` and
`label.theme` can be defined as `element_text_interactive` (in fact,
they will be converted to that if they are not already), either directly
or via the theme. See the element\_\*\_interactive section for more
details.

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe.md)

Other interactive scale:
[`scale_alpha_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_alpha_interactive.md),
[`scale_colour_brewer_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_colour_brewer_interactive.md),
[`scale_colour_interactive`](https://davidgohel.github.io/ggiraph/dev/reference/scale_colour_interactive.md),
[`scale_colour_steps_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_colour_steps_interactive.md),
[`scale_gradient_interactive`](https://davidgohel.github.io/ggiraph/dev/reference/scale_gradient_interactive.md),
[`scale_linetype_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_linetype_interactive.md),
[`scale_manual_interactive`](https://davidgohel.github.io/ggiraph/dev/reference/scale_manual_interactive.md),
[`scale_size_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_size_interactive.md),
[`scale_viridis_interactive`](https://davidgohel.github.io/ggiraph/dev/reference/scale_viridis_interactive.md)
