# Create interactive theme elements

With these functions the user can add interactivity to various
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
elements.

They are based on
[`ggplot2::element_rect()`](https://ggplot2.tidyverse.org/reference/element.html),
[`ggplot2::element_line()`](https://ggplot2.tidyverse.org/reference/element.html)
and
[`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
See the documentation for those functions for more details.

## Usage

``` r
element_line_interactive(...)

element_rect_interactive(...)

element_text_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md).

## Details for element\_\*\_interactive functions

The interactive parameters can be supplied as arguments in the relevant
function and they should be scalar values.

For theme text elements (`element_text_interactive()`), the interactive
parameters can also be supplied while setting a label value, via the
[`ggplot2::labs()`](https://ggplot2.tidyverse.org/reference/labs.html)
family of functions or when setting a scale/guide title or key label.
Instead of setting a character value for the element, function
[`label_interactive()`](https://davidgohel.github.io/ggiraph/reference/label_interactive.md)
can be used to define interactive parameters to go along with the label.
When the parameters are supplied that way, they override the default
values that are set at the theme via `element_text_interactive()` or via
the `guide`'s theme parameters.

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)

## Examples

``` r
# add interactive theme elements -------
library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()
#> [1] TRUE

dataset <- structure(
  list(
    qsec = c(16.46, 17.02, 18.61, 19.44, 17.02, 20.22),
    disp = c(160, 160, 108, 258, 360, 225),
    carname = c(
      "Mazda RX4",
      "Mazda RX4 Wag",
      "Datsun 710",
      "Hornet 4 Drive",
      "Hornet Sportabout",
      "Valiant"
    ),
    wt = c(2.62, 2.875, 2.32, 3.215, 3.44, 3.46)
  ),
  row.names = c(
    "Mazda RX4",
    "Mazda RX4 Wag",
    "Datsun 710",
    "Hornet 4 Drive",
    "Hornet Sportabout",
    "Valiant"
  ),
  class = "data.frame"
)

# plots
gg_point = ggplot(data = dataset) +
  geom_point_interactive(aes(
    x = wt,
    y = qsec,
    color = disp,
    tooltip = carname,
    data_id = carname
  )) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11) +
  theme(
    plot.title = element_text_interactive(
      data_id = "plot.title",
      tooltip = "plot title",
      hover_css = "fill:red;stroke:none;font-size:12pt"
    ),
    plot.subtitle = element_text_interactive(
      data_id = "plot.subtitle",
      tooltip = "plot subtitle",
      hover_css = "fill:none;"
    ),
    axis.title.x = element_text_interactive(
      data_id = "axis.title.x",
      tooltip = "Description for x axis",
      hover_css = "fill:red;stroke:none;"
    ),
    axis.title.y = element_text_interactive(
      data_id = "axis.title.y",
      tooltip = "Description for y axis",
      hover_css = "fill:red;stroke:none;"
    ),
    panel.grid.major = element_line_interactive(
      data_id = "panel.grid",
      tooltip = "Major grid lines",
      hover_css = "fill:none;stroke:red;"
    )
  ) +
  labs(
    title = "Interactive points example!",
    subtitle = label_interactive(
      "by ggiraph",
      tooltip = "Click me!",
      onclick = "window.open(\"https://davidgohel.github.io/ggiraph/\")",
      hover_css = "fill:magenta;cursor:pointer;"
    )
  )

x <- girafe(
  ggobj = gg_point,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}
```
