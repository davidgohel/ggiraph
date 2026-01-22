# Create interactive bars

The geometries are based on
[`ggplot2::geom_bar()`](https://ggplot2.tidyverse.org/reference/geom_bar.html)
and
[`ggplot2::geom_col()`](https://ggplot2.tidyverse.org/reference/geom_bar.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_bar_interactive(...)

geom_col_interactive(...)
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
library(gdtools)

register_liberationsans()
#> [1] TRUE

p <- ggplot(mpg, aes(x = class, tooltip = class, data_id = class)) +
  geom_bar_interactive() +
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

dat <- data.frame(
  name = c("David", "Constance", "Leonie"),
  gender = c("Male", "Female", "Female"),
  height = c(172, 159, 71)
)
p <- ggplot(dat, aes(x = name, y = height, tooltip = gender, data_id = name)) +
  geom_col_interactive() +
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

# an example with interactive guide ----
dat <- data.frame(
  name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
  gender = c("Male", "Female", "Male", "Male", "Male"),
  height = c(169, 160, 171, 172, 171)
)
p <- ggplot(dat, aes(x = name, y = height, fill = gender, data_id = name)) +
  geom_bar_interactive(stat = "identity") +
  scale_fill_manual_interactive(
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = c(Female = "Female", Male = "Male"),
    tooltip = c(Male = "Male", Female = "Female")
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
```
