# Create interactive histograms and frequency polygons

The geometries are based on
[`ggplot2::geom_histogram()`](https://ggplot2.tidyverse.org/reference/geom_histogram.html)
and
[`ggplot2::geom_freqpoly()`](https://ggplot2.tidyverse.org/reference/geom_histogram.html).
See the documentation for those functions for more details.

This interactive version is only providing a single tooltip per group of
data (same for `data_id`). It means it is only possible to associate a
single tooltip to a set of bins.

## Usage

``` r
geom_freqpoly_interactive(...)

geom_histogram_interactive(...)
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
# add interactive histogram -------
library(ggplot2)
library(ggiraph)

p <- ggplot(diamonds, aes(carat)) +
  geom_histogram_interactive(
    bins = 30,
    aes(tooltip = after_stat(count), group = 1L)
  )
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

p <- ggplot(diamonds, aes(price, colour = cut, tooltip = cut, data_id = cut)) +
  geom_freqpoly_interactive(binwidth = 500)
x <- girafe(ggobj = p)
x <- girafe_options(x = x, opts_hover(css = "stroke-width:3px;"))
if (interactive()) {
  print(x)
}
```
