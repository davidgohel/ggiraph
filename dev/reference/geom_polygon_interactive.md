# Create interactive polygons

The geometry is based on
[`ggplot2::geom_polygon()`](https://ggplot2.tidyverse.org/reference/geom_polygon.html).
See the documentation for those functions for more details.

## Usage

``` r
geom_polygon_interactive(...)
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
# add interactive polygons to a ggplot -------
library(ggplot2)
library(ggiraph)

# create data
ids <- factor(c("1.1", "2.1", "1.2", "2.2", "1.3", "2.3"))

values <- data.frame(
  id = ids,
  value = c(3, 3.1, 3.1, 3.2, 3.15, 3.5)
)
positions <- data.frame(
  id = rep(ids, each = 4),
  x = c(
    2,
    1,
    1.1,
    2.2,
    1,
    0,
    0.3,
    1.1,
    2.2,
    1.1,
    1.2,
    2.5,
    1.1,
    0.3,
    0.5,
    1.2,
    2.5,
    1.2,
    1.3,
    2.7,
    1.2,
    0.5,
    0.6,
    1.3
  ),
  y = c(
    -0.5,
    0,
    1,
    0.5,
    0,
    0.5,
    1.5,
    1,
    0.5,
    1,
    2.1,
    1.7,
    1,
    1.5,
    2.2,
    2.1,
    1.7,
    2.1,
    3.2,
    2.8,
    2.1,
    2.2,
    3.3,
    3.2
  )
)

datapoly <- merge(values, positions, by = c("id"))

datapoly$oc = "alert(this.getAttribute(\"data-id\"))"

# create a ggplot -----
gg_poly_1 <- ggplot(datapoly, aes(x = x, y = y)) +
  geom_polygon_interactive(aes(
    fill = value,
    group = id,
    tooltip = value,
    data_id = value,
    onclick = oc
  ))

# display ------
x <- girafe(ggobj = gg_poly_1)
if (interactive()) {
  print(x)
}

if (packageVersion("grid") >= "3.6") {
  # As of R version 3.6 geom_polygon() supports polygons with holes
  # Use the subgroup aesthetic to differentiate holes from the main polygon

  holes <- do.call(
    rbind,
    lapply(split(datapoly, datapoly$id), function(df) {
      df$x <- df$x + 0.5 * (mean(df$x) - df$x)
      df$y <- df$y + 0.5 * (mean(df$y) - df$y)
      df
    })
  )
  datapoly$subid <- 1L
  holes$subid <- 2L
  datapoly <- rbind(datapoly, holes)
  p <- ggplot(datapoly, aes(x = x, y = y)) +
    geom_polygon_interactive(aes(
      fill = value,
      group = id,
      subgroup = subid,
      tooltip = value,
      data_id = value,
      onclick = oc
    ))
  x <- girafe(ggobj = p)
  if (interactive()) print(x)
}
```
