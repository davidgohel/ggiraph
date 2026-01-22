# Create interactive quantile regression

The geometry is based on
[`ggplot2::geom_quantile()`](https://ggplot2.tidyverse.org/reference/geom_quantile.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_quantile_interactive(...)
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
# add interactive quantiles to a ggplot -------
library(ggplot2)
library(ggiraph)

if (requireNamespace("quantreg", quietly = TRUE)) {
  m <- ggplot(mpg, aes(displ, 1 / hwy)) + geom_point()
  p <- m +
    geom_quantile_interactive(
      aes(
        tooltip = after_stat(quantile),
        data_id = after_stat(quantile),
        colour = after_stat(quantile)
      ),
      formula = y ~ x,
      size = 2,
      alpha = 0.5
    )
  x <- girafe(ggobj = p)
  x <- girafe_options(x = x, opts_hover(css = "stroke:red;stroke-width:10px;"))
  if (interactive()) print(x)
}
```
