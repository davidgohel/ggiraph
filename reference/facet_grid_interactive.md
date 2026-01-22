# Create interactive grid facets

These facets are based on
[`ggplot2::facet_grid()`](https://ggplot2.tidyverse.org/reference/facet_grid.html).

To make a facet interactive, it is mandatory to use
[`labeller_interactive()`](https://davidgohel.github.io/ggiraph/reference/labeller_interactive.md)
for argument `labeller`.

## Usage

``` r
facet_grid_interactive(..., interactive_on = "text")
```

## Arguments

- ...:

  arguments passed to base function and
  [`labeller_interactive()`](https://davidgohel.github.io/ggiraph/reference/labeller_interactive.md)
  for argument `labeller`.

- interactive_on:

  one of 'text' (only strip text are made interactive), 'rect' (only
  strip rectangles are made interactive) or 'both' (strip text and
  rectangles are made interactive).

## Value

An interactive facetting object.

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)
