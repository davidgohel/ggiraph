# Create interactive smoothed conditional means

The geometry is based on
[`ggplot2::geom_smooth()`](https://ggplot2.tidyverse.org/reference/geom_smooth.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_smooth_interactive(...)
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
# add interactive bar -------
library(ggplot2)
library(ggiraph)

p <- ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_smooth_interactive(aes(tooltip = "smoothed line", data_id = "smooth"))
x <- girafe(ggobj = p)
#> `geom_smooth()` using method = 'loess' and formula = 'y ~ x'
x <- girafe_options(x = x, opts_hover(css = "stroke:orange;stroke-width:3px;"))
if (interactive()) {
  print(x)
}

p <- ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_smooth_interactive(
    method = lm,
    se = FALSE,
    tooltip = "smooth",
    data_id = "smooth"
  )
x <- girafe(ggobj = p)
#> `geom_smooth()` using formula = 'y ~ x'
if (interactive()) {
  print(x)
}

p <- ggplot(
  mpg,
  aes(displ, hwy, colour = class, tooltip = class, data_id = class)
) +
  geom_point_interactive() +
  geom_smooth_interactive(se = FALSE, method = lm)
x <- girafe(ggobj = p)
#> `geom_smooth()` using formula = 'y ~ x'
x <- girafe_options(x = x, opts_hover(css = "stroke:red;stroke-width:3px;"))
if (interactive()) {
  print(x)
}
```
