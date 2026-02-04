# Tooltip settings

Settings to be used with
[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
for tooltip customisation.

## Usage

``` r
opts_tooltip(
  css = NULL,
  offx = 10,
  offy = 0,
  use_cursor_pos = TRUE,
  opacity = 0.9,
  use_fill = FALSE,
  use_stroke = FALSE,
  delay_mouseover = 200,
  delay_mouseout = 500,
  placement = c("auto", "doc", "container"),
  zindex = 9999
)
```

## Arguments

- css:

  extra css (added to `position: absolute;pointer-events: none;`) used
  to customize tooltip area.

- offx, offy:

  tooltip x and y offset

- use_cursor_pos:

  should the cursor position be used to position tooltip (in addition to
  offx and offy). Setting to TRUE will have no effect in the RStudio
  browser windows.

- opacity:

  tooltip background opacity

- use_fill, use_stroke:

  logical, use fill and stroke properties to color tooltip.

- delay_mouseover:

  The duration in milliseconds of the transition associated with tooltip
  display.

- delay_mouseout:

  The duration in milliseconds of the transition associated with tooltip
  end of display.

- placement:

  Defines the container used for the tooltip element. It can be one of
  "auto" (default), "doc" or "container".

  - doc: the host document's body is used as tooltip container. The
    tooltip may cover areas outside of the svg graphic.

  - container: the svg container is used as tooltip container. In this
    case the tooltip content may wrap to fit inside the svg bounds. It
    will also inherit the CSS styles and transforms applied to the
    parent containers (like scaling in a slide presentation).

  - auto: This is the default, ggiraph choses the best option according
    to use cases. Usually it redirects to "doc", however in a *xaringan*
    context, it redirects to "container".

- zindex:

  tooltip css z-index, default to 999.

## See also

Other girafe animation options:
[`girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/girafe_defaults.md),
[`girafe_options()`](https://davidgohel.github.io/ggiraph/reference/girafe_options.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md),
[`opts_selection()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md),
[`opts_sizing()`](https://davidgohel.github.io/ggiraph/reference/opts_sizing.md),
[`opts_toolbar()`](https://davidgohel.github.io/ggiraph/reference/opts_toolbar.md),
[`opts_zoom()`](https://davidgohel.github.io/ggiraph/reference/opts_zoom.md),
[`set_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/set_girafe_defaults.md)

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
  opts_tooltip(opacity = .7,
    offx = 20, offy = -10,
    use_fill = TRUE, use_stroke = TRUE,
    delay_mouseout = 1000) )
if( interactive() ) print(x)
```
