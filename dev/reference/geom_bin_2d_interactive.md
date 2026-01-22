# Create interactive heatmaps of 2d bin counts

The geometry is based on
[`ggplot2::geom_bin_2d()`](https://ggplot2.tidyverse.org/reference/geom_bin_2d.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_bin_2d_interactive(...)
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
# add interactive bin2d heatmap to a ggplot -------
library(ggplot2)
library(ggiraph)

p <- ggplot(diamonds, aes(x, y, fill = cut)) +
  xlim(4, 10) +
  ylim(4, 10) +
  geom_bin2d_interactive(aes(tooltip = cut), bins = 30)

x <- girafe(ggobj = p)
#> Warning: Removed 478 rows containing non-finite outside the scale range
#> (`stat_bin2d()`).
#> Warning: Removed 15 rows containing missing values or values outside the scale range
#> (`geom_interactive_tile()`).
if (interactive()) {
  print(x)
}
```
