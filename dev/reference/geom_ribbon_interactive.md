# Create interactive ribbons and area plots

The geometries are based on
[`ggplot2::geom_ribbon()`](https://ggplot2.tidyverse.org/reference/geom_ribbon.html)
and
[`ggplot2::geom_area()`](https://ggplot2.tidyverse.org/reference/geom_ribbon.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_ribbon_interactive(...)

geom_area_interactive(...)
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
# add interactive bar -------
library(ggplot2)
library(ggiraph)

# Generate data
huron <- data.frame(year = 1875:1972, level = as.vector(LakeHuron))
h <- ggplot(huron, aes(year))

g <- h +
  geom_ribbon_interactive(
    aes(ymin = level - 1, ymax = level + 1),
    fill = "grey70",
    tooltip = "ribbon1",
    data_id = "ribbon1",
    outline.type = "both",
    hover_css = "stroke:red;stroke-width:inherit;"
  ) +
  geom_line_interactive(
    aes(y = level),
    tooltip = "level",
    data_id = "line1",
    hover_css = "stroke:orange;fill:none;"
  )
x <- girafe(ggobj = g)
x <- girafe_options(
  x = x,
  opts_hover(
    css = girafe_css(
      css = "stroke:orange;stroke-width:3px;",
      area = "fill:blue;"
    )
  )
)
if (interactive()) {
  print(x)
}


g <- h + geom_area_interactive(aes(y = level), tooltip = "area1")
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}
```
