# CSS creation helper

It allows specifying individual styles for various SVG elements.

## Usage

``` r
girafe_css(
  css,
  text = NULL,
  point = NULL,
  line = NULL,
  area = NULL,
  image = NULL
)
```

## Arguments

- css:

  The generic css style

- text:

  Override style for text elements (svg:text)

- point:

  Override style for point elements (svg:circle)

- line:

  Override style for line elements (svg:line, svg:polyline)

- area:

  Override style for area elements (svg:rect, svg:polygon, svg:path)

- image:

  Override style for image elements (svg:image)

## Value

css as scalar character

## See also

[`girafe_css_bicolor()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe_css_bicolor.md),
[`girafe()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe.md)

## Examples

``` r
library(ggiraph)

girafe_css(
  css = "fill:orange;stroke:gray;",
  text = "stroke:none; font-size: larger",
  line = "fill:none",
  area = "stroke-width:3px",
  point = "stroke-width:3px",
  image = "outline:2px red"
)
#> [1] "/*GIRAFE CSS*/._CLASSNAME_ { fill:orange;stroke:gray; }\ntext._CLASSNAME_ { stroke:none; font-size: larger }\ncircle._CLASSNAME_ { stroke-width:3px }\nline._CLASSNAME_, polyline._CLASSNAME_ { fill:none }\nrect._CLASSNAME_, polygon._CLASSNAME_, path._CLASSNAME_ { stroke-width:3px }\nimage._CLASSNAME_ { outline:2px red }"
```
