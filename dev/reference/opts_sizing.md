# Girafe sizing settings

Allows customization of the svg style sizing

## Usage

``` r
opts_sizing(rescale = TRUE, width = 1)
```

## Arguments

- rescale:

  If FALSE, graphic will not be resized and the dimensions are exactly
  those of the svg. If TRUE the graphic will be resize to fit its
  container

- width:

  widget width ratio (0 \< width \<= 1).

## See also

Other girafe animation options:
[`girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_defaults.md),
[`girafe_options()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_options.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_hover.md),
[`opts_selection()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_selection.md),
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
  opts_sizing(rescale = FALSE) )
if( interactive() ) print(x)
```
