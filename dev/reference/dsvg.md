# SVG Graphics Driver

This function produces SVG files (compliant to the current w3 svg XML
standard) where elements can be made interactive.

In order to generate the output, used fonts must be available on the
computer used to create the svg, used fonts must also be available on
the computer used to render the svg.

## Usage

``` r
dsvg(
  file = "Rplots.svg",
  width = 6,
  height = 6,
  bg = "white",
  pointsize = 12,
  standalone = TRUE,
  setdims = TRUE,
  canvas_id = "svg_1",
  title = NULL,
  desc = NULL,
  fonts = list()
)
```

## Arguments

- file:

  the file where output will appear.

- height, width:

  Height and width in inches.

- bg:

  Default background color for the plot (defaults to "white").

- pointsize:

  default point size.

- standalone:

  Produce a stand alone svg file? If `FALSE`, omits xml header and
  default namespace.

- setdims:

  If `TRUE` (the default), the svg node will have attributes width &
  height set.

- canvas_id:

  svg id within HTML page.

- title:

  A label for accessibility purposes (aria-label/aria-labelledby). Be
  aware that when using this, the browser will use it as a tooltip for
  the whole svg and it may class with the interactive elements' tooltip.

- desc:

  A longer description for accessibility purposes
  (aria-description/aria-describedby).

- fonts:

  Named list of font names to be aliased with fonts installed on your
  system. If unspecified, the defaults from
  [`gdtools::font_set_liberation()`](https://davidgohel.github.io/gdtools/reference/font_set_liberation.html)
  are used for the R families "sans", "serif", "mono" and "symbol".

  As an example, using `fonts = list(sans = "Roboto")` would make the
  default font "Roboto" as many ggplot themes use
  `theme_minimal(base_family = "sans")`.

## See also

[Devices](https://rdrr.io/r/grDevices/Devices.html)

## Examples

``` r
fileout <- tempfile(fileext = ".svg")
dsvg(file = fileout)
plot(rnorm(10), main="Simple Example", xlab = "", ylab = "")
dev.off()
#> agg_record_841068614 
#>                    2 
```
