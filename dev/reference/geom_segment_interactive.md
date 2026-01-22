# Create interactive line segments and curves

The geometries are based on
[`ggplot2::geom_segment()`](https://ggplot2.tidyverse.org/reference/geom_segment.html)
and
[`ggplot2::geom_curve()`](https://ggplot2.tidyverse.org/reference/geom_segment.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_curve_interactive(...)

geom_segment_interactive(...)
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
# add interactive segments and curves to a ggplot -------
library(ggplot2)
library(ggiraph)

counts <- as.data.frame(table(x = rpois(100, 5)))
counts$x <- as.numeric(as.character(counts$x))
counts$xlab <- paste0("bar", as.character(counts$x))

gg_segment_1 <- ggplot(
  data = counts,
  aes(x = x, y = Freq, yend = 0, xend = x, tooltip = xlab)
) +
  geom_segment_interactive(size = I(10))
x <- girafe(ggobj = gg_segment_1)
if (interactive()) {
  print(x)
}

dataset = data.frame(
  x = c(1, 2, 5, 6, 8),
  y = c(3, 6, 2, 8, 7),
  vx = c(1, 1.5, 0.8, 0.5, 1.3),
  vy = c(0.2, 1.3, 1.7, 0.8, 1.4),
  labs = paste0("Lab", 1:5)
)
dataset$clickjs = paste0("alert(\"", dataset$labs, "\")")

gg_segment_2 = ggplot() +
  geom_segment_interactive(
    data = dataset,
    mapping = aes(
      x = x,
      y = y,
      xend = x + vx,
      yend = y + vy,
      tooltip = labs,
      onclick = clickjs
    ),
    arrow = grid::arrow(length = grid::unit(0.03, "npc")),
    size = 2,
    color = "blue"
  ) +
  geom_point(
    data = dataset,
    mapping = aes(x = x, y = y),
    size = 4,
    shape = 21,
    fill = "white"
  )

x <- girafe(ggobj = gg_segment_2)
if (interactive()) {
  print(x)
}

df <- data.frame(x1 = 2.62, x2 = 3.57, y1 = 21.0, y2 = 15.0)
p <- ggplot(df, aes(x = x1, y = y1, xend = x2, yend = y2)) +
  geom_curve_interactive(aes(colour = "curve", tooltip = I("curve"))) +
  geom_segment_interactive(aes(colour = "segment", tooltip = I("segment")))

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
```
