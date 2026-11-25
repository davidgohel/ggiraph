# Run plotting code and view svg in RStudio Viewer or web browser

`dsvg_view()` is deprecated: draw with
[`dsvg()`](https://davidgohel.github.io/ggiraph/dev/reference/dsvg.md)
directly, or display an interactive graphic with
[`girafe()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe.md).

## Usage

``` r
dsvg_view(code, ...)
```

## Arguments

- code:

  Plotting code to execute.

- ...:

  Other arguments passed on to
  [`dsvg()`](https://davidgohel.github.io/ggiraph/dev/reference/dsvg.md).
