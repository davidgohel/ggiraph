# Create interactive raster grob

The grob is based on `rasterGrob()`. See the documentation for that
function for more details.

## Usage

``` r
interactive_raster_grob(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md).

## Value

An interactive grob object.

## Details for interactive\_\*\_grob functions

The interactive parameters can be supplied as arguments in the relevant
function and they can be scalar values or vectors depending on params on
base function.

## See also

[interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md),
[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
