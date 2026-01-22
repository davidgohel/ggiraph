# Selection effect settings

Allows customization of the rendering of selected graphic elements. Use
`opts_selection` for interactive geometries in panels,
`opts_selection_key` for interactive scales/guides and
`opts_selection_theme` for interactive theme elements. Use
`opts_selection_inv` for the effect on the rest of the geometries, while
some are selected (inverted operation).

## Usage

``` r
opts_selection(
  css = NULL,
  type = c("multiple", "single", "none"),
  only_shiny = TRUE,
  selected = character(0)
)

opts_selection_inv(css = NULL)

opts_selection_key(
  css = NULL,
  type = c("single", "multiple", "none"),
  only_shiny = TRUE,
  selected = character(0)
)

opts_selection_theme(
  css = NULL,
  type = c("single", "multiple", "none"),
  only_shiny = TRUE,
  selected = character(0)
)
```

## Arguments

- css:

  css to associate with elements when they are selected. It must be a
  scalar character. It can also be constructed with
  [`girafe_css()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_css.md),
  to give more control over the css for different element types.

- type:

  selection mode ("single", "multiple", "none") when widget is in a
  Shiny application.

- only_shiny:

  disable selections when not running within a Shiny application.
  Defaults to `TRUE` because selection is primarily designed for Shiny
  interactivity, where selected elements can be captured as reactive
  values. Set to `FALSE` only to demonstrate the selection/lasso feature
  in standalone HTML pages (e.g. in documentation examples or R Markdown
  output).

- selected:

  character vector, id to be selected when the graph will be
  initialized.

## Note

**IMPORTANT**: When applying a `fill` style with the `css` argument, be
aware that the browser's CSS engine will apply it also to line elements,
if there are any that use the selection feature. This will cause an
undesired effect.

To overcome this, supply the argument `css` using
[`girafe_css()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_css.md),
in order to set the `fill` style only for the desired elements.

## See also

[`girafe_css()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_css.md),
[`girafe_css_bicolor()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_css_bicolor.md)

Other girafe animation options:
[`girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_defaults.md),
[`girafe_options()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_options.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_hover.md),
[`opts_sizing()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_sizing.md),
[`opts_toolbar()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_toolbar.md),
[`opts_tooltip()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_tooltip.md),
[`opts_zoom()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_zoom.md),
[`set_girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/set_girafe_defaults.md)

## Examples

``` r
library(ggplot2)

dataset <- mtcars
dataset$carname = row.names(mtcars)

gg <- ggplot(
  data = dataset,
  mapping = aes(x = wt, y = qsec, color = disp,
                tooltip = carname, data_id = carname) ) +
  geom_point_interactive() + theme_minimal()

x <- girafe(ggobj = gg)
x <- girafe_options(x,
  opts_selection(type = "multiple", only_shiny = FALSE,
    css = "fill:red;stroke:gray;r:5pt;") )
if( interactive() ) print(x)
```
