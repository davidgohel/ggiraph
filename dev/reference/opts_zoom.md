# Zoom settings

Allows customization of the zoom.

## Usage

``` r
opts_zoom(min = 1, max = 1, duration = 300, default_on = FALSE)
```

## Arguments

- min:

  minimum zoom factor

- max:

  maximum zoom factor

- duration:

  duration of the zoom transitions, in milliseconds

- default_on:

  if TRUE, pan/zoom will be activated by default when the plot is
  rendered

## See also

Other girafe animation options:
[`girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_defaults.md),
[`girafe_options()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_options.md),
[`init_girafe_defaults()`](https://davidgohel.github.io/ggiraph/dev/reference/init_girafe_defaults.md),
[`opts_hover()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_hover.md),
[`opts_selection()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_selection.md),
[`opts_sizing()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_sizing.md),
[`opts_toolbar()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_toolbar.md),
[`opts_tooltip()`](https://davidgohel.github.io/ggiraph/dev/reference/opts_tooltip.md),
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
  opts_zoom(min = .7, max = 2, default_on = TRUE) )
if( interactive() ) print(x)
```
