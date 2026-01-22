# Hover effect settings

Allows customization of the rendering of graphic elements when the user
hovers over them with the cursor (mouse pointer). Use `opts_hover` for
interactive geometries in panels, `opts_hover_key` for interactive
scales/guides and `opts_hover_theme` for interactive theme elements. Use
`opts_hover_inv` for the effect on the rest of the geometries, while one
is hovered (inverted operation).

## Usage

``` r
opts_hover(css = NULL, reactive = FALSE, nearest_distance = NULL)

opts_hover_inv(css = NULL)

opts_hover_key(css = NULL, reactive = FALSE)

opts_hover_theme(css = NULL, reactive = FALSE)
```

## Arguments

- css:

  css to associate with elements when they are hovered. It must be a
  scalar character. It can also be constructed with
  [`girafe_css()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_css.md),
  to give more control over the css for different element types.

- reactive:

  if TRUE, in Shiny context, hovering will set Shiny input values.

- nearest_distance:

  a scalar positive number defining the maximum distance to use when
  using the `hover_nearest` [interactive
  parameter](https://davidgohel.github.io/ggiraph/dev/reference/interactive_parameters.md)
  feature. By default (`NULL`) it's set to `Infinity` which means that
  there is no distance limit. Setting it to 50, for example, it will
  hover the nearest element that has at maximum 50 SVG units (pixels)
  distance from the mouse cursor.

## Note

**IMPORTANT**: When applying a `fill` style with the `css` argument, be
aware that the browser's CSS engine will apply it also to line elements,
if there are any that use the hovering feature. This will cause an
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
[`opts_selection()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_selection.md),
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
  opts_hover(css = "fill:wheat;stroke:orange;r:5pt;") )
if( interactive() ) print(x)
```
