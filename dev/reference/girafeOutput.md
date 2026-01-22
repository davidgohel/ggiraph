# Create a girafe output element

Render a girafe within an application page.

## Usage

``` r
girafeOutput(outputId, width = "100%", height = NULL)
```

## Arguments

- outputId:

  output variable to read the girafe from. Do not use special JavaScript
  characters such as a period `.` in the id, this would create a
  JavaScript error.

- width:

  widget width, its default value is set so that the graphic can cover
  the entire available horizontal space.

- height:

  widget height, its default value is NULL so that width adaptation is
  not restricted. The height will then be defined according to the width
  used and the aspect ratio. Only use a value for the height if you have
  a specific reason and want to strictly control the size.

## Size control

If you want to control a fixed size, use `opts_sizing(rescale = FALSE)`
and set the chart size with `girafe(width_svg=..., height_svg=...)`.

If you want the graphic to fit the available width, use
`opts_sizing(rescale = TRUE)` and set the size of the graphic with
`girafe(width_svg=..., height_svg=...)`, this size will define the
aspect ratio.
