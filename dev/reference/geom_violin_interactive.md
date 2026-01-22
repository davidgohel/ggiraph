# Create interactive violin plot

The geometry is based on
[`ggplot2::geom_violin()`](https://ggplot2.tidyverse.org/reference/geom_violin.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_violin_interactive(...)
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
# add interactive violin plot -------
library(ggplot2)
library(ggiraph)

p <- ggplot(mtcars, aes(factor(cyl), mpg)) +
  geom_violin_interactive(aes(fill = cyl, tooltip = cyl))
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

# Show quartiles
p2 <- ggplot(mtcars, aes(factor(cyl), mpg)) +
  geom_violin_interactive(
    aes(tooltip = after_stat(density)),
    draw_quantiles = c(0.25, 0.5, 0.75)
  )
x2 <- girafe(ggobj = p2)
if (interactive()) {
  print(x2)
}
```
