# Create interactive jittered points

The geometry is based on
[`ggplot2::geom_jitter()`](https://ggplot2.tidyverse.org/reference/geom_jitter.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_jitter_interactive(...)
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
# add interactive paths to a ggplot -------
library(ggplot2)
library(ggiraph)

gg_jitter <- ggplot(
  mpg,
  aes(cyl, hwy, tooltip = paste(manufacturer, model, year, trans, sep = "\n"))
) +
  geom_jitter_interactive()

x <- girafe(ggobj = gg_jitter)
if (interactive()) {
  print(x)
}
```
