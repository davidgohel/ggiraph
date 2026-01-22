# Set girafe options

Defines the animation options related to a
[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
object.

## Usage

``` r
girafe_options(x, ...)
```

## Arguments

- x:

  girafe object.

- ...:

  set of options defined by calls to `opts_*` functions or to
  sizingPolicy from htmlwidgets (this won't have any effect within a
  shiny context).

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md),
[`girafe_css()`](https://davidgohel.github.io/ggiraph/reference/girafe_css.md),
[`girafe_css_bicolor()`](https://davidgohel.github.io/ggiraph/reference/girafe_css_bicolor.md)

Other girafe animation options:
[`girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/girafe_defaults.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/reference/opts_hover.md),
[`opts_selection()`](https://davidgohel.github.io/ggiraph/reference/opts_selection.md),
[`opts_sizing()`](https://davidgohel.github.io/ggiraph/reference/opts_sizing.md),
[`opts_toolbar()`](https://davidgohel.github.io/ggiraph/reference/opts_toolbar.md),
[`opts_tooltip()`](https://davidgohel.github.io/ggiraph/reference/opts_tooltip.md),
[`opts_zoom()`](https://davidgohel.github.io/ggiraph/reference/opts_zoom.md),
[`set_girafe_defaults()`](https://davidgohel.github.io/ggiraph/reference/set_girafe_defaults.md)

## Examples

``` r
library(ggplot2)
library(htmlwidgets)

dataset <- mtcars
dataset$carname = row.names(mtcars)

gg_point = ggplot( data = dataset,
    mapping = aes(x = wt, y = qsec, color = disp,
    tooltip = carname, data_id = carname) ) +
  geom_point_interactive() + theme_minimal()

x <- girafe(ggobj = gg_point)
x <- girafe_options(x = x,
    opts_tooltip(opacity = .7),
    opts_zoom(min = .5, max = 4),
    sizingPolicy(defaultWidth = "100%", defaultHeight = "300px"),
    opts_hover(css = "fill:red;stroke:orange;r:5pt;") )

if(interactive()){
  print(x)
}
```
