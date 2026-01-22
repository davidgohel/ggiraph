# Create interactive reference lines

These geometries are based on
[`ggplot2::geom_abline()`](https://ggplot2.tidyverse.org/reference/geom_abline.html),
[`ggplot2::geom_hline()`](https://ggplot2.tidyverse.org/reference/geom_abline.html)
and
[`ggplot2::geom_vline()`](https://ggplot2.tidyverse.org/reference/geom_abline.html).

## Usage

``` r
geom_abline_interactive(...)

geom_hline_interactive(...)

geom_vline_interactive(...)
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

[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)

[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)

## Examples

``` r
# add diagonal interactive reference lines to a ggplot -------
library(ggplot2)
library(ggiraph)

p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
g <- p + geom_abline_interactive(intercept = 20, tooltip = 20)
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

l <- coef(lm(mpg ~ wt, data = mtcars))
g <- p +
  geom_abline_interactive(
    intercept = l[[1]],
    slope = l[[2]],
    tooltip = paste("intercept:", l[[1]], "\nslope:", l[[2]]),
    data_id = "abline"
  )
x <- girafe(ggobj = g)
x <- girafe_options(
  x = x,
  opts_hover(css = "cursor:pointer;fill:orange;stroke:orange;")
)
if (interactive()) {
  print(x)
}
# add horizontal interactive reference lines to a ggplot -------
library(ggplot2)
library(ggiraph)

if (requireNamespace("dplyr", quietly = TRUE)) {
  g1 <- ggplot(economics, aes(x = date, y = unemploy)) +
    geom_point() +
    geom_line()

  gg_hline1 <- g1 +
    geom_hline_interactive(
      aes(yintercept = mean(unemploy), tooltip = round(mean(unemploy), 2)),
      linewidth = 3
    )
  x <- girafe(ggobj = gg_hline1)
  if (interactive()) print(x)
}

dataset <- data.frame(
  x = c(1, 2, 5, 6, 8),
  y = c(3, 6, 2, 8, 7),
  vx = c(1, 1.5, 0.8, 0.5, 1.3),
  vy = c(0.2, 1.3, 1.7, 0.8, 1.4),
  year = c(2014, 2015, 2016, 2017, 2018)
)

dataset$clickjs <- rep(paste0("alert(\"", mean(dataset$y), "\")"), 5)


g2 <- ggplot(dataset, aes(x = year, y = y)) +
  geom_point() +
  geom_line()

gg_hline2 <- g2 +
  geom_hline_interactive(
    aes(
      yintercept = mean(y),
      tooltip = round(mean(y), 2),
      data_id = y,
      onclick = clickjs
    )
  )

x <- girafe(ggobj = gg_hline2)
if (interactive()) {
  print(x)
}
# add vertical interactive reference lines to a ggplot -------
library(ggplot2)
library(ggiraph)

if (requireNamespace("dplyr", quietly = TRUE)) {
  g1 <- ggplot(diamonds, aes(carat)) +
    geom_histogram()

  gg_vline1 <- g1 +
    geom_vline_interactive(
      aes(
        xintercept = mean(carat),
        tooltip = round(mean(carat), 2),
        data_id = carat
      ),
      size = 3
    )
  x <- girafe(ggobj = gg_vline1)
  if (interactive()) print(x)
}
#> Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
#> ℹ Please use `linewidth` instead.
#> ℹ The deprecated feature was likely used in the ggiraph package.
#>   Please report the issue at <https://github.com/davidgohel/ggiraph/issues>.
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.

dataset <- data.frame(x = rnorm(100))

dataset$clickjs <- rep(
  paste0("alert(\"", round(mean(dataset$x), 2), "\")"),
  100
)

g2 <- ggplot(dataset, aes(x)) +
  geom_density(fill = "#000000", alpha = 0.7)
gg_vline2 <- g2 +
  geom_vline_interactive(
    aes(
      xintercept = mean(x),
      tooltip = round(mean(x), 2),
      data_id = x,
      onclick = clickjs
    ),
    color = "white"
  )

x <- girafe(ggobj = gg_vline2)
x <- girafe_options(
  x = x,
  opts_hover(css = "cursor:pointer;fill:orange;stroke:orange;")
)
if (interactive()) {
  print(x)
}
```
