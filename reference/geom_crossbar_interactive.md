# Create interactive vertical intervals: lines, crossbars & errorbars

These geometries are based on
[`ggplot2::geom_crossbar()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html),
[`ggplot2::geom_errorbar()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html),
[`ggplot2::geom_linerange()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html)
and
[`ggplot2::geom_pointrange()`](https://ggplot2.tidyverse.org/reference/geom_linerange.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_crossbar_interactive(...)

geom_errorbar_interactive(...)

geom_linerange_interactive(...)

geom_pointrange_interactive(...)
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
# add interactive intervals -------
library(ggplot2)
library(ggiraph)

# Create a simple example dataset
df <- data.frame(
  trt = factor(c(1, 1, 2, 2)),
  resp = c(1, 5, 3, 4),
  group = factor(c(1, 2, 1, 2)),
  upper = c(1.1, 5.3, 3.3, 4.2),
  lower = c(0.8, 4.6, 2.4, 3.6)
)

p <- ggplot(df, aes(trt, resp, colour = group))


g <- p +
  geom_linerange_interactive(aes(ymin = lower, ymax = upper, tooltip = group))
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

g <- p +
  geom_pointrange_interactive(aes(ymin = lower, ymax = upper, tooltip = group))
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

g <- p +
  geom_crossbar_interactive(
    aes(ymin = lower, ymax = upper, tooltip = group),
    width = 0.2
  )
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

g <- p +
  geom_errorbar_interactive(
    aes(ymin = lower, ymax = upper, tooltip = group),
    width = 0.2
  )
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}
```
