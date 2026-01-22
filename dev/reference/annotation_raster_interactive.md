# Create interactive raster annotations

The layer is based on
[`ggplot2::annotation_raster()`](https://ggplot2.tidyverse.org/reference/annotation_raster.html).
See the documentation for that function for more details.

## Usage

``` r
annotation_raster_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/dev/reference/interactive_parameters.md).

## Details for annotate\_\*\_interactive functions

The interactive parameters can be supplied as arguments in the relevant
function and they can be scalar values or vectors depending on params on
base function.

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe.md)

## Examples

``` r
# add interactive raster annotation to a ggplot -------
library(ggplot2)
library(ggiraph)

# Generate data
rainbow <- matrix(hcl(seq(0, 360, length.out = 50 * 50), 80, 70), nrow = 50)
p <- ggplot(mtcars, aes(mpg, wt)) +
  geom_point() +
  annotation_raster_interactive(
    rainbow,
    15,
    20,
    3,
    4,
    tooltip = "I am an image!"
  )
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

# To fill up whole plot
p <- ggplot(mtcars, aes(mpg, wt)) +
  annotation_raster_interactive(
    rainbow,
    -Inf,
    Inf,
    -Inf,
    Inf,
    tooltip = "I am an image too!"
  ) +
  geom_point()
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
```
