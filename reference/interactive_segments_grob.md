# Create interactive segments grob

The grob is based on
[segmentsGrob](https://rdrr.io/r/grid/grid.segments.html). See the
documentation for that function for more details.

## Usage

``` r
interactive_segments_grob(...)
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

[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
