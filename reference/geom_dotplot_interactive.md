# Create interactive dot plots

This geometry is based on
[`ggplot2::geom_dotplot()`](https://ggplot2.tidyverse.org/reference/geom_dotplot.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_dotplot_interactive(...)
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
# add interactive dot plots to a ggplot -------
library(ggplot2)
library(ggiraph)

p <- ggplot(mtcars, aes(x = mpg, fill = factor(cyl))) +
  geom_dotplot_interactive(
    aes(tooltip = row.names(mtcars)),
    stackgroups = TRUE,
    binwidth = 1,
    method = "histodot"
  )

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

gg_point = ggplot(
  data = mtcars,
  mapping = aes(
    x = factor(vs),
    fill = factor(cyl),
    y = mpg,
    tooltip = row.names(mtcars)
  )
) +
  geom_dotplot_interactive(
    binaxis = "y",
    stackdir = "center",
    position = "dodge"
  )

x <- girafe(ggobj = gg_point)
#> Bin width defaults to 1/30 of the range of the data. Pick better value with
#> `binwidth`.
if (interactive()) {
  print(x)
}
```
