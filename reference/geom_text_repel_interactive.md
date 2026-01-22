# Create interactive repulsive textual annotations

The geometries are based on
[`ggrepel::geom_text_repel()`](https://ggrepel.slowkow.com/reference/geom_text_repel.html)
and
[`ggrepel::geom_label_repel()`](https://ggrepel.slowkow.com/reference/geom_text_repel.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_text_repel_interactive(...)

geom_label_repel_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md).

## Note

The `ggrepel` package is required for these geometries

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
# add interactive repulsive texts to a ggplot -------
library(ggplot2)
library(ggiraph)

# geom_text_repel_interactive
if (requireNamespace("ggrepel", quietly = TRUE)) {
  dataset = mtcars
  dataset$label = row.names(mtcars)
  dataset$tooltip = paste0(
    dataset$label,
    "<br/>",
    "cyl: ",
    dataset$cyl,
    "<br/>",
    "gear: ",
    dataset$gear,
    "<br/>",
    "carb: ",
    dataset$carb
  )
  p <- ggplot(dataset, aes(wt, mpg, color = qsec)) +
    geom_point_interactive(aes(tooltip = tooltip, data_id = label))

  gg_text = p +
    geom_text_repel_interactive(
      aes(label = label, tooltip = tooltip, data_id = label),
      size = 3
    )

  x <- girafe(ggobj = gg_text)
  x <- girafe_options(x = x, opts_hover(css = "fill:#FF4C3B;"))
  if (interactive()) print(x)
}

# geom_label_repel_interactive
if (requireNamespace("ggrepel", quietly = TRUE)) {
  gg_label = p +
    geom_label_repel_interactive(
      aes(label = label, tooltip = tooltip, data_id = label),
      size = 3,
      max.overlaps = 12
    )

  x2 <- girafe(ggobj = gg_label)
  x2 <- girafe_options(
    x = x2,
    opts_hover(
      css = ggiraph::girafe_css(
        css = ";",
        area = "fill:#FF4C3B;"
      )
    )
  )
  if (interactive()) print(x2)
}
```
