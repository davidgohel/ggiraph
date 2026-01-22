# Create interactive polyline grob

These grobs are based on `polylineGrob()` and `linesGrob()`. See the
documentation for those functions for more details.

## Usage

``` r
interactive_polyline_grob(...)

interactive_lines_grob(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/dev/reference/interactive_parameters.md).

## Value

An interactive grob object.

## Details for interactive\_\*\_grob functions

The interactive parameters can be supplied as arguments in the relevant
function and they can be scalar values or vectors depending on params on
base function.

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe.md)
