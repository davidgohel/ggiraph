# Create interactive point counts

The geometry is based on
[`ggplot2::geom_bin2d()`](https://ggplot2.tidyverse.org/reference/geom_bin_2d.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_count_interactive(...)
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
# add interactive point counts to a ggplot -------
library(ggplot2)
library(ggiraph)

p <- ggplot(mpg, aes(cty, hwy)) +
  geom_count_interactive(aes(tooltip = after_stat(n)))
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

p2 <- ggplot(diamonds, aes(x = cut, y = clarity)) +
  geom_count_interactive(aes(
    size = after_stat(prop),
    tooltip = after_stat(round(prop, 3)),
    group = 1
  )) +
  scale_size_area(max_size = 10)
x <- girafe(ggobj = p2)
if (interactive()) {
  print(x)
}
```
