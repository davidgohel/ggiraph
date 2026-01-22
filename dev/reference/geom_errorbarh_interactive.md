# Create interactive horizontal error bars

This geometry is based on
[`ggplot2::geom_errorbarh()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_errorbarh_interactive(...)
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
# add horizontal error bars -------
library(ggplot2)
library(ggiraph)

df <- data.frame(
  trt = factor(c(1, 1, 2, 2)),
  resp = c(1, 5, 3, 4),
  group = factor(c(1, 2, 1, 2)),
  se = c(0.1, 0.3, 0.3, 0.2)
)

# Define the top and bottom of the errorbars

p <- ggplot(df, aes(resp, trt, colour = group))
g <- p +
  geom_point() +
  geom_errorbarh_interactive(aes(
    xmax = resp + se,
    xmin = resp - se,
    tooltip = group
  ))
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}
```
