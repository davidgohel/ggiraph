# Create interactive line segments parameterised by location, direction and distance

The geometry is based on
[`ggplot2::geom_spoke()`](https://ggplot2.tidyverse.org/reference/geom_spoke.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_spoke_interactive(...)
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
# add interactive line segments parameterised by location,
# direction and distance to a ggplot -------
library(ggplot2)
library(ggiraph)

df <- expand.grid(x = 1:10, y = 1:10)
df$angle <- runif(100, 0, 2 * pi)
df$speed <- runif(100, 0, sqrt(0.1 * df$x))

p <- ggplot(df, aes(x, y)) +
  geom_point() +
  geom_spoke_interactive(
    aes(angle = angle, tooltip = round(angle, 2)),
    radius = 0.5
  )
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

p2 <- ggplot(df, aes(x, y)) +
  geom_point() +
  geom_spoke_interactive(aes(
    angle = angle,
    radius = speed,
    tooltip = paste(round(angle, 2), round(speed, 2), sep = "\n")
  ))
x2 <- girafe(ggobj = p2)
if (interactive()) {
  print(x2)
}
```
