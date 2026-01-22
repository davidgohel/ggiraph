# Create your own interactive discrete scale

These scales are based on
[`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html),
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html),
[`ggplot2::scale_size_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html),
[`ggplot2::scale_shape_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html),
[`ggplot2::scale_linetype_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html),
[`ggplot2::scale_alpha_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
and
[`ggplot2::scale_discrete_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).
See the documentation for those functions for more details.

## Usage

``` r
scale_colour_manual_interactive(...)

scale_color_manual_interactive(...)

scale_fill_manual_interactive(...)

scale_size_manual_interactive(...)

scale_shape_manual_interactive(...)

scale_linetype_manual_interactive(...)

scale_alpha_manual_interactive(...)

scale_discrete_manual_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function, plus any of the
  [interactive_parameters](https://davidgohel.github.io/ggiraph/reference/interactive_parameters.md).

## Value

An interactive scale object.

## Details for interactive scale and interactive guide functions

For scales, the interactive parameters can be supplied as arguments in
the relevant function and they can be scalar values or vectors,
depending on the number of breaks (levels) and the type of the guide
used. The guides do not accept any interactive parameter directly, they
receive them from the scales.

When guide of type `legend`, `bins`, `colourbar` or `coloursteps` is
used, it will be converted to a
[`guide_legend_interactive()`](https://davidgohel.github.io/ggiraph/reference/guide_legend_interactive.md),
[`guide_bins_interactive()`](https://davidgohel.github.io/ggiraph/reference/guide_bins_interactive.md),
[`guide_colourbar_interactive()`](https://davidgohel.github.io/ggiraph/reference/guide_colourbar_interactive.md)
or
[`guide_coloursteps_interactive()`](https://davidgohel.github.io/ggiraph/reference/guide_coloursteps_interactive.md)
respectively, if it's not already.

The length of each scale interactive parameter vector should match the
length of the breaks. It can also be a named vector, where each name
should correspond to the same break name. It can also be defined as
function that takes the breaks as input and returns a named or unnamed
vector of values as output.

For binned guides like `bins` and `coloursteps` the breaks include the
label breaks and the limits. The number of bins will be one less than
the number of breaks and the interactive parameters can be constructed
for each bin separately (look at the examples). For `colourbar` guide in
raster mode, the breaks vector, is scalar 1 always, meaning the
interactive parameters should be scalar too. For `colourbar` guide in
non-raster mode, the bar is drawn using rectangles, and the breaks are
the midpoints of each rectangle.

The interactive parameters here, give interactivity only to the key
elements of the guide.

To provide interactivity to the rest of the elements of a guide, (title,
labels, background, etc), the relevant theme elements or relevant guide
arguments can be used. The `guide` arguments `title.theme` and
`label.theme` can be defined as `element_text_interactive` (in fact,
they will be converted to that if they are not already), either directly
or via the theme. See the element\_\*\_interactive section for more
details.

## See also

[`girafe()`](https://davidgohel.github.io/ggiraph/reference/girafe.md)

Other interactive scale:
[`scale_alpha_interactive()`](https://davidgohel.github.io/ggiraph/reference/scale_alpha_interactive.md),
[`scale_colour_brewer_interactive()`](https://davidgohel.github.io/ggiraph/reference/scale_colour_brewer_interactive.md),
[`scale_colour_interactive`](https://davidgohel.github.io/ggiraph/reference/scale_colour_interactive.md),
[`scale_colour_steps_interactive()`](https://davidgohel.github.io/ggiraph/reference/scale_colour_steps_interactive.md),
[`scale_gradient_interactive`](https://davidgohel.github.io/ggiraph/reference/scale_gradient_interactive.md),
[`scale_linetype_interactive()`](https://davidgohel.github.io/ggiraph/reference/scale_linetype_interactive.md),
[`scale_shape_interactive()`](https://davidgohel.github.io/ggiraph/reference/scale_shape_interactive.md),
[`scale_size_interactive()`](https://davidgohel.github.io/ggiraph/reference/scale_size_interactive.md),
[`scale_viridis_interactive`](https://davidgohel.github.io/ggiraph/reference/scale_viridis_interactive.md)

## Examples

``` r
# add interactive manual fill scale to a ggplot -------
library(ggplot2)
library(ggiraph)

dat <- data.frame(
  name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
  gender = c("Male", "Female", "Male", "Male", "Male"),
  height = c(169, 160, 171, 172, 171)
)
p <- ggplot(dat, aes(x = name, y = height, fill = gender, data_id = name)) +
  geom_bar_interactive(stat = "identity")

# add interactive scale (guide is legend)
p1 <- p +
  scale_fill_manual_interactive(
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = c(Female = "Female", Male = "Male"),
    tooltip = c(Male = "Male", Female = "Female")
  )
x <- girafe(ggobj = p1)
if (interactive()) {
  print(x)
}

# make the title interactive too
p2 <- p +
  scale_fill_manual_interactive(
    name = label_interactive(
      "gender",
      tooltip = "Gender levels",
      data_id = "legend.title"
    ),
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = c(Female = "Female", Male = "Male"),
    tooltip = c(Male = "Male", Female = "Female")
  )
x <- girafe(ggobj = p2)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}

# the interactive params can be functions too
p3 <- p +
  scale_fill_manual_interactive(
    name = label_interactive(
      "gender",
      tooltip = "Gender levels",
      data_id = "legend.title"
    ),
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = function(breaks) {
      as.character(breaks)
    },
    tooltip = function(breaks) {
      as.character(breaks)
    },
    onclick = function(breaks) {
      paste0("alert(\"", as.character(breaks), "\")")
    }
  )
x <- girafe(ggobj = p3)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}

# also via the guide
p4 <- p +
  scale_fill_manual_interactive(
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = function(breaks) {
      as.character(breaks)
    },
    tooltip = function(breaks) {
      as.character(breaks)
    },
    onclick = function(breaks) {
      paste0("alert(\"", as.character(breaks), "\")")
    },
    guide = guide_legend_interactive(
      title.theme = element_text_interactive(
        size = 8,
        data_id = "legend.title",
        onclick = "alert(\"Gender levels\")",
        tooltip = "Gender levels"
      ),
      label.theme = element_text_interactive(
        size = 8
      )
    )
  )
x <- girafe(ggobj = p4)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}

# make the legend labels interactive
p5 <- p +
  scale_fill_manual_interactive(
    name = label_interactive(
      "gender",
      tooltip = "Gender levels",
      data_id = "legend.title"
    ),
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = function(breaks) {
      as.character(breaks)
    },
    tooltip = function(breaks) {
      as.character(breaks)
    },
    onclick = function(breaks) {
      paste0("alert(\"", as.character(breaks), "\")")
    },
    labels = function(breaks) {
      lapply(breaks, function(br) {
        label_interactive(
          as.character(br),
          data_id = as.character(br),
          onclick = paste0("alert(\"", as.character(br), "\")"),
          tooltip = as.character(br)
        )
      })
    }
  )
x <- girafe(ggobj = p5)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}
```
