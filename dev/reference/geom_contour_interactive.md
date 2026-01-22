# Create interactive 2d contours of a 3d surface

These geometries are based on
[`ggplot2::geom_contour()`](https://ggplot2.tidyverse.org/reference/geom_contour.html)
and
[`ggplot2::geom_contour_filled()`](https://ggplot2.tidyverse.org/reference/geom_contour.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_contour_interactive(...)

geom_contour_filled_interactive(...)
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

v <- ggplot(faithfuld, aes(waiting, eruptions, z = density))
p <- v +
  geom_contour_interactive(aes(
    colour = after_stat(level),
    tooltip = paste("Level:", after_stat(level))
  ))
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

if (packageVersion("grid") >= numeric_version("3.6")) {
  p <- v +
    geom_contour_filled_interactive(aes(
      colour = after_stat(level),
      fill = after_stat(level),
      tooltip = paste("Level:", after_stat(level))
    ))
  x <- girafe(ggobj = p)
  if (interactive()) print(x)
}
```
