# Run plotting code and view svg in RStudio Viewer or web broswer.

This is useful primarily for testing. Requires the `htmltools` package.

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

## Examples

``` r
# \donttest{
dsvg_view(plot(1:10))
dsvg_view(hist(rnorm(100)))
# }
```
