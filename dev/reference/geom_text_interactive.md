# Create interactive textual annotations

The geometries are based on
[`ggplot2::geom_text()`](https://ggplot2.tidyverse.org/reference/geom_text.html)
and
[`ggplot2::geom_label()`](https://ggplot2.tidyverse.org/reference/geom_text.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_label_interactive(...)

geom_text_interactive(...)
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
# add interactive labels to a ggplot -------
library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()
#> [1] TRUE

p <- ggplot(mtcars, aes(wt, mpg, label = rownames(mtcars))) +
  geom_label_interactive(
    aes(
      tooltip = paste(rownames(mtcars), mpg, sep = "\n")
    ),
    family = "Liberation Sans"
  ) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)
x <- girafe(
  ggobj = p,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}


p <- ggplot(mtcars, aes(wt, mpg, label = rownames(mtcars))) +
  geom_label_interactive(
    aes(fill = factor(cyl), tooltip = paste(rownames(mtcars), mpg, sep = "\n")),
    colour = "white",
    fontface = "bold",
    family = "Liberation Sans"
  ) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)
x <- girafe(
  ggobj = p,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}
# add interactive texts to a ggplot -------
library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()
#> [1] TRUE

## the data
dataset = mtcars
dataset$label = row.names(mtcars)

dataset$tooltip = paste0(
  "cyl: ",
  dataset$cyl,
  "<br/>",
  "gear: ",
  dataset$gear,
  "<br/>",
  "carb: ",
  dataset$carb
)

## the plot
gg_text = ggplot(
  dataset,
  aes(
    x = mpg,
    y = wt,
    label = label,
    color = qsec,
    tooltip = tooltip,
    data_id = label
  )
) +
  geom_text_interactive(check_overlap = TRUE, family = "Liberation Sans") +
  coord_cartesian(xlim = c(0, 50)) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

## display the plot
x <- girafe(
  ggobj = gg_text,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
x <- girafe_options(x = x, opts_hover(css = "fill:#FF4C3B;font-style:italic;"))
if (interactive()) {
  print(x)
}
```
