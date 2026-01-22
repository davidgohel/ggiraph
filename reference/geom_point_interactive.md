# Create interactive points

The geometry is based on
[`ggplot2::geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_point_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md).

## Note

The following shapes id 3, 4 and 7 to 14 are composite symbols and
should not be used.

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
# add interactive points to a ggplot -------
library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()
#> [1] TRUE

dataset <- structure(
  list(
    qsec = c(16.46, 17.02, 18.61, 19.44, 17.02, 20.22),
    disp = c(160, 160, 108, 258, 360, 225),
    carname = c(
      "Mazda RX4",
      "Mazda RX4 Wag",
      "Datsun 710",
      "Hornet 4 Drive",
      "Hornet Sportabout",
      "Valiant"
    ),
    wt = c(2.62, 2.875, 2.32, 3.215, 3.44, 3.46)
  ),
  row.names = c(
    "Mazda RX4",
    "Mazda RX4 Wag",
    "Datsun 710",
    "Hornet 4 Drive",
    "Hornet Sportabout",
    "Valiant"
  ),
  class = "data.frame"
)
dataset
#>                    qsec disp           carname    wt
#> Mazda RX4         16.46  160         Mazda RX4 2.620
#> Mazda RX4 Wag     17.02  160     Mazda RX4 Wag 2.875
#> Datsun 710        18.61  108        Datsun 710 2.320
#> Hornet 4 Drive    19.44  258    Hornet 4 Drive 3.215
#> Hornet Sportabout 17.02  360 Hornet Sportabout 3.440
#> Valiant           20.22  225           Valiant 3.460

# plots
gg_point = ggplot(data = dataset) +
  geom_point_interactive(aes(
    x = wt,
    y = qsec,
    color = disp,
    tooltip = carname,
    data_id = carname
  )) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

x <- girafe(
  ggobj = gg_point,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}
```
