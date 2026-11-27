# Create interactive colour scales

These scales are based on
[`ggplot2::scale_colour_continuous()`](https://ggplot2.tidyverse.org/reference/scale_colour_continuous.html),
[`ggplot2::scale_fill_continuous()`](https://ggplot2.tidyverse.org/reference/scale_colour_continuous.html),
[`ggplot2::scale_colour_grey()`](https://ggplot2.tidyverse.org/reference/scale_grey.html),
[`ggplot2::scale_fill_grey()`](https://ggplot2.tidyverse.org/reference/scale_grey.html),
[`ggplot2::scale_colour_hue()`](https://ggplot2.tidyverse.org/reference/scale_hue.html),
[`ggplot2::scale_fill_hue()`](https://ggplot2.tidyverse.org/reference/scale_hue.html),
[`ggplot2::scale_colour_binned()`](https://ggplot2.tidyverse.org/reference/scale_colour_continuous.html),
[`ggplot2::scale_fill_binned()`](https://ggplot2.tidyverse.org/reference/scale_colour_continuous.html),
[`ggplot2::scale_colour_discrete()`](https://ggplot2.tidyverse.org/reference/scale_colour_discrete.html),
[`ggplot2::scale_fill_discrete()`](https://ggplot2.tidyverse.org/reference/scale_colour_discrete.html),
[`ggplot2::scale_colour_date()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html),
[`ggplot2::scale_fill_date()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html),
[`ggplot2::scale_colour_datetime()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
and
[`ggplot2::scale_fill_datetime()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html).
See the documentation for those functions for more details.

## Usage

``` r
scale_colour_continuous_interactive(...)

scale_color_continuous_interactive(...)

scale_fill_continuous_interactive(...)

scale_colour_grey_interactive(...)

scale_color_grey_interactive(...)

scale_fill_grey_interactive(...)

scale_colour_hue_interactive(...)

scale_color_hue_interactive(...)

scale_fill_hue_interactive(...)

scale_colour_binned_interactive(...)

scale_color_binned_interactive(...)

scale_fill_binned_interactive(...)

scale_colour_discrete_interactive(...)

scale_color_discrete_interactive(...)

scale_fill_discrete_interactive(...)

scale_colour_date_interactive(...)

scale_color_date_interactive(...)

scale_fill_date_interactive(...)

scale_colour_datetime_interactive(...)

scale_color_datetime_interactive(...)

scale_fill_datetime_interactive(...)
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

The interactive parameters follow what 'ggplot2' draws: one value per
key drawn in the legend.

For the `bins` and `coloursteps` guides the breaks include the label
breaks and the limits, sorted in increasing order, also with
`reverse = TRUE`. There is one class (one key, or one rectangle) less
than breaks: a vector or a function can give one value per class or one
per break, and each class takes the value of its lower bound (a single
value is given to every class). The interactive parameters can be
constructed for each class separately (look at the examples).

The `colourbar` guide (with the default `display = "raster"` or with
`display = "gradient"`) draws the bar as a single element: each
interactive parameter must be a single value, given for the whole bar
(e.g. `data_id = "bar"`). A function still receives the breaks of the
scale, the ones labelled in the legend, and must return a single value
(e.g. `data_id = function(breaks) paste(breaks, collapse = "-")`);
several values give a warning and the parameter is not set. With
`display = "rectangles"`, the `colourbar` guide draws one rectangle per
colour and the breaks are the midpoints of each rectangle.

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
[`scale_colour_steps_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_colour_steps_interactive.md),
[`scale_gradient_interactive`](https://davidgohel.github.io/ggiraph/dev/reference/scale_gradient_interactive.md),
[`scale_linetype_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_linetype_interactive.md),
[`scale_linewidth_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_linewidth_interactive.md),
[`scale_manual_interactive`](https://davidgohel.github.io/ggiraph/dev/reference/scale_manual_interactive.md),
[`scale_shape_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_shape_interactive.md),
[`scale_size_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/scale_size_interactive.md),
[`scale_viridis_interactive`](https://davidgohel.github.io/ggiraph/dev/reference/scale_viridis_interactive.md)
