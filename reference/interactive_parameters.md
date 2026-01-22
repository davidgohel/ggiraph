# Interactive parameters

Throughout ggiraph there are functions that add interactivity to ggplot
plot elements. The user can control the various aspects of interactivity
by supplying a special set of parameters to these functions.

## Arguments

- tooltip:

  Tooltip text to associate with one or more elements. If this is
  supplied a tooltip is shown when the element is hovered. Plain text or
  html is supported.

  To use html markup it is advised to use
  [`htmltools::HTML()`](https://rstudio.github.io/htmltools/reference/HTML.html)
  function in order to mark the text as html markup. If the text is not
  marked as html and no opening/closing tags were detected, then any
  existing newline characters (`\r\n`, `\r` and `\n`) are replaced with
  the `<br/>` tag.

- onclick:

  Javascript code to associate with one or more elements. This code will
  be executed when the element is clicked.

- hover_css:

  Individual css style associate with one or more elements. This css
  style is applied when the element is hovered and overrides the default
  style, set via
  [`opts_hover()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md),
  [`opts_hover_key()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md)
  or
  [`opts_hover_theme()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md).
  It can also be constructed with
  [`girafe_css()`](https://davidgohel.github.io/ggiraph/reference/girafe_css.md),
  to give more control over the css for different element types (see
  [`opts_hover()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md)
  note).

- selected_css:

  Individual css style associate with one or more elements. This css
  style is applied when the element is selected and overrides the
  default style, set via
  [`opts_selection()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md),
  [`opts_selection_key()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md)
  or
  [`opts_selection_theme()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md).
  It can also be constructed with
  [`girafe_css()`](https://davidgohel.github.io/ggiraph/reference/girafe_css.md),
  to give more control over the css for different element types (see
  [`opts_selection()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md)
  note).

- data_id:

  Identifier to associate with one or more elements. This is mandatory
  parameter if hover and selection interactivity is desired. Identifiers
  are available as reactive input values in Shiny applications.

- tooltip_fill:

  Color to use for tooltip background when
  [`opts_tooltip()`](https://davidgohel.github.io/ggiraph/reference/opts_tooltip.md)
  `use_fill` is TRUE. Useful for setting the tooltip background color in
  [`geom_text_interactive()`](https://davidgohel.github.io/ggiraph/reference/geom_text_interactive.md)
  or
  [`geom_label_interactive()`](https://davidgohel.github.io/ggiraph/reference/geom_text_interactive.md),
  when the geom text color may be the same as the tooltip text color.

- hover_nearest:

  Set to TRUE to apply the hover effect on the nearest element while
  moving the mouse. In this case it is mandatory to also set the
  `data_id` parameter

## Details for interactive geom functions

The interactive parameters can be supplied with two ways:

- As aesthetics with the mapping argument (via
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html)).
  In this way they can be mapped to data columns and apply to a set of
  geometries.

- As plain arguments into the geom\_\*\_interactive function. In this
  way they can be set to a scalar value.

## Details for annotate\_\*\_interactive functions

The interactive parameters can be supplied as arguments in the relevant
function and they can be scalar values or vectors depending on params on
base function.

## Details for interactive scale and interactive guide functions

For scales, the interactive parameters can be supplied as arguments in
the relevant function and they can be scalar values or vectors,
depending on the number of breaks (levels) and the type of the guide
used. The guides do not accept any interactive parameter directly, they
receive them from the scales.

When guide of type `legend`, `bins`, `colourbar` or `coloursteps` is
used, it will be converted to a
[`guide_legend_interactive()`](https://davidgohel.github.io/ggiraph/reference/guide_legend_interactive.md),
[`guide_bins_interactive()`](https://davidgohel.github.io/ggiraph/reference/guide_bins_interactive.md),
[`guide_colourbar_interactive()`](https://davidgohel.github.io/ggiraph/reference/guide_colourbar_interactive.md)
or
[`guide_coloursteps_interactive()`](https://davidgohel.github.io/ggiraph/reference/guide_coloursteps_interactive.md)
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

## Details for element\_\*\_interactive functions

The interactive parameters can be supplied as arguments in the relevant
function and they should be scalar values.

For theme text elements
([`element_text_interactive()`](https://davidgohel.github.io/ggiraph/reference/element_interactive.md)),
the interactive parameters can also be supplied while setting a label
value, via the
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
family of functions or when setting a scale/guide title or key label.
Instead of setting a character value for the element, function
[`label_interactive()`](https://davidgohel.github.io/ggiraph/reference/label_interactive.md)
can be used to define interactive parameters to go along with the label.
When the parameters are supplied that way, they override the default
values that are set at the theme via
[`element_text_interactive()`](https://davidgohel.github.io/ggiraph/reference/element_interactive.md)
or via the `guide`'s theme parameters.

## Details for interactive\_\*\_grob functions

The interactive parameters can be supplied as arguments in the relevant
function and they can be scalar values or vectors depending on params on
base function.

## Custom interactive parameters

The argument `extra_interactive_params` can be passed to any of the
\*\_interactive functions (geoms, grobs, scales, labeller, labels and
theme elements), It should be a character vector of additional names to
be treated as interactive parameters when evaluating the aesthetics. The
values will eventually end up as attributes in the SVG elements of the
output.

Intended only for expert use.

## See also

[`girafe_options()`](https://davidgohel.github.io/ggiraph/reference/girafe_options.md),
[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
