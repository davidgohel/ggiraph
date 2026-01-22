# Create interactive quasirandom geom

The geometry is based on
[`ggbeeswarm::geom_quasirandom()`](https://rdrr.io/pkg/ggbeeswarm/man/geom_quasirandom.html).

## Usage

``` r
geom_quasirandom_interactive(...)
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
# add interactive repulsive texts to a ggplot -------
library(ggplot2)
library(ggiraph)

# geom_text_repel_interactive
if (
  requireNamespace("ggbeeswarm", quietly = TRUE) &&
    requireNamespace("dplyr", quietly = TRUE)
) {
  set.seed(2)

  dat <- dplyr::filter(
    .data = diamonds,
    cut %in% c("Fair", "Good"),
    color %in% c("D", "E", "H")
  )
  dat <- dplyr::sample_n(tbl = dat, 150)

  dodge_width <- .8
  position <- position_dodge(width = dodge_width)

  gg_qr <- ggplot(dat, aes(x = cut, y = y, fill = color)) +
    geom_violin(
      alpha = .5,
      width = dodge_width
    ) +
    geom_boxplot(position = position, alpha = .5, outliers = FALSE) +
    geom_quasirandom_interactive(
      aes(tooltip = y, data_id = color),
      shape = 21,
      size = 2,
      dodge.width = dodge_width,
      color = "black",
      alpha = .5
    ) +
    theme_minimal()

  x <- girafe(ggobj = gg_qr)
  x <- girafe_options(x = x, opts_hover(css = "fill:#FF4C3B;"))
  if (interactive()) print(x)




  dat <- mtcars
  dat$name <- row.names(mtcars)
  dat$am <- factor(dat$am)
  dat$gear <- factor(dat$gear)

  dodge_width <- .8
  position <- position_dodge(width = dodge_width)

  gg_qr <- ggplot(
    dat,
    aes(x = am, y = disp, fill = gear, group = interaction(am, gear))
  ) +
    geom_quasirandom_interactive(
      aes(tooltip = disp, data_id = name),
      shape = 21,
      size = 2,
      dodge.width = dodge_width,
      color = "black"
    ) +
    scale_fill_manual_interactive(
      name = label_interactive(
        "Gearrrrrr",
        tooltip = "Gearrrrrr",
        data_id = "gear"
      ),
      values = c("3" = "#0072B2", "4" = "#009E73", "5" = "red"),
      data_id = c("3" = "tree", "4" = "tree", "5" = "four"),
      tooltip = c("3" = "tree", "4" = "tree", "5" = "four")
    ) +
    theme_minimal()

  x <- girafe(ggobj = gg_qr)
  if (interactive()) print(x)
}
```
