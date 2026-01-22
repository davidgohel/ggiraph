# Create interactive contours of a 2d density estimate

The geometries are based on
[`ggplot2::geom_density_2d()`](https://ggplot2.tidyverse.org/reference/geom_density_2d.html)
and
[`ggplot2::geom_density_2d_filled()`](https://ggplot2.tidyverse.org/reference/geom_density_2d.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_density_2d_interactive(...)

geom_density_2d_filled_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/dev/reference/interactive_parameters.md).

## Details for interactive geom functions

The interactive parameters can be supplied with two ways:

- As aesthetics with the mapping argument (via
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html)).
  In this way they can be mapped to data columns and apply to a set of
  geometries.

- As plain arguments into the geom\_\*\_interactive function. In this
  way they can be set to a scalar value.

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe.md)

## Examples

``` r
# add interactive contours to a ggplot -------
library(ggplot2)
library(ggiraph)

m <- ggplot(faithful, aes(x = eruptions, y = waiting)) +
  geom_point_interactive(aes(
    tooltip = paste("Waiting:", waiting, "\neruptions:", eruptions)
  )) +
  xlim(0.5, 6) +
  ylim(40, 110)
p <- m +
  geom_density_2d_interactive(aes(tooltip = paste("Level:", after_stat(level))))
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

set.seed(4393)
dsmall <- diamonds[sample(nrow(diamonds), 1000), ]
d <- ggplot(dsmall, aes(x, y))


p <- d +
  geom_density_2d_interactive(aes(colour = cut, tooltip = cut, data_id = cut))
x <- girafe(ggobj = p)
x <- girafe_options(x = x, opts_hover(css = "stroke:red;stroke-width:3px;"))
if (interactive()) {
  print(x)
}

p <- d +
  geom_density_2d_filled_interactive(
    aes(colour = cut, tooltip = cut, data_id = cut),
    contour_var = "count"
  ) +
  facet_wrap(vars(cut))
x <- girafe(ggobj = p)
x <- girafe_options(x = x, opts_hover(css = "stroke:red;stroke-width:3px;"))
if (interactive()) {
  print(x)
}


p <- d +
  stat_density_2d(
    aes(
      fill = after_stat(nlevel),
      tooltip = paste("nlevel:", after_stat(nlevel))
    ),
    geom = "interactive_polygon"
  ) +
  facet_grid(. ~ cut) +
  scale_fill_viridis_c_interactive(tooltip = "nlevel")
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
```
