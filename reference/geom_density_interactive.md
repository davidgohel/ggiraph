# Create interactive smoothed density estimates

The geometry is based on
[`ggplot2::geom_density()`](https://ggplot2.tidyverse.org/reference/geom_density.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_density_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md).

## Details for interactive geom functions

The interactive parameters can be supplied with two ways:

- As aesthetics with the mapping argument (via
  [`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html)).
  In this way they can be mapped to data columns and apply to a set of
  geometries.

- As plain arguments into the geom\_\*\_interactive function. In this
  way they can be set to a scalar value.

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)

## Examples

``` r
# add interactive bar -------
library(ggplot2)
library(ggiraph)

p <- ggplot(diamonds, aes(carat)) +
  geom_density_interactive(tooltip = "density", data_id = "density")
x <- girafe(ggobj = p)
x <- girafe_options(x = x, opts_hover(css = "stroke:orange;stroke-width:3px;"))
if (interactive()) {
  print(x)
}

p <- ggplot(diamonds, aes(depth, fill = cut, colour = cut)) +
  geom_density_interactive(aes(tooltip = cut, data_id = cut), alpha = 0.1) +
  xlim(55, 70)
x <- girafe(ggobj = p)
#> Warning: Removed 45 rows containing non-finite outside the scale range
#> (`stat_density()`).
x <- girafe_options(
  x = x,
  opts_hover(css = "stroke:yellow;stroke-width:3px;fill-opacity:0.8;")
)
if (interactive()) {
  print(x)
}


p <- ggplot(diamonds, aes(carat, fill = cut)) +
  geom_density_interactive(
    aes(tooltip = cut, data_id = cut),
    position = "stack"
  )
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

p <- ggplot(diamonds, aes(carat, after_stat(count), fill = cut)) +
  geom_density_interactive(aes(tooltip = cut, data_id = cut), position = "fill")
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
```
