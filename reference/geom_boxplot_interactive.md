# Create interactive boxplot

The geometry is based on
[`ggplot2::geom_boxplot()`](https://ggplot2.tidyverse.org/reference/geom_boxplot.html).
See the documentation for that function for more details.

## Usage

``` r
geom_boxplot_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md).

## Details

You can supply `interactive parameters` for the outlier points by
prefixing them with `outlier.` prefix. For example: aes(outlier.tooltip
= 'bla', outlier.data_id = 'blabla').

IMPORTANT: when supplying outlier interactive parameters, the correct
`group` aesthetic *must* be also supplied. Otherwise the default group
calculation will be incorrect, which will result in an incorrect plot.

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
# add interactive boxplot -------
library(ggplot2)
library(ggiraph)

p <- ggplot(mpg, aes(x = class, y = hwy, tooltip = class)) +
  geom_boxplot_interactive()

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

p <- ggplot(mpg) +
  geom_boxplot_interactive(
    aes(
      x = drv,
      y = hwy,
      fill = class,
      data_id = class,
      tooltip = after_stat({
        paste0(
          "class: ",
          .data$fill,
          "\nQ1: ",
          prettyNum(.data$lower),
          "\nQ3: ",
          prettyNum(.data$upper),
          "\nmedian: ",
          prettyNum(.data$middle)
        )
      })
    ),
    outlier.colour = "red"
  ) +
  guides(fill = "none") +
  theme_minimal()

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}


p <- ggplot(mpg) +
  geom_boxplot_interactive(
    aes(
      x = drv,
      y = hwy,
      fill = class,
      group = paste(drv, class),
      data_id = class,
      tooltip = after_stat({
        paste0(
          "class: ",
          .data$fill,
          "\nQ1: ",
          prettyNum(.data$lower),
          "\nQ3: ",
          prettyNum(.data$upper),
          "\nmedian: ",
          prettyNum(.data$middle)
        )
      }),
      outlier.tooltip = paste(
        "I am an outlier!\nhwy:",
        hwy,
        "\ndrv:",
        drv,
        "\nclass:",
        class
      )
    ),
    outlier.colour = "red"
  ) +
  guides(fill = "none") +
  theme_minimal()

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
```
