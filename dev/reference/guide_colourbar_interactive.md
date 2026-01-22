# Create interactive continuous colour bar guide

The guide is based on
[`ggplot2::guide_colourbar()`](https://ggplot2.tidyverse.org/reference/guide_colourbar.html).
See the documentation for that function for more details.

## Usage

``` r
guide_colourbar_interactive(...)

guide_colorbar_interactive(...)
```

## Arguments

- ...:

  arguments passed to base function.

## Value

An interactive guide object.

## Details for interactive scale and interactive guide functions

For scales, the interactive parameters can be supplied as arguments in
the relevant function and they can be scalar values or vectors,
depending on the number of breaks (levels) and the type of the guide
used. The guides do not accept any interactive parameter directly, they
receive them from the scales.

When guide of type `legend`, `bins`, `colourbar` or `coloursteps` is
used, it will be converted to a
[`guide_legend_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/guide_legend_interactive.md),
[`guide_bins_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/guide_bins_interactive.md),
`guide_colourbar_interactive()` or
[`guide_coloursteps_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/guide_coloursteps_interactive.md)
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

[interactive_parameters](https://davidgohel.github.io/ggiraph/dev/reference/interactive_parameters.md),
[`girafe()`](https://davidgohel.github.io/ggiraph/dev/reference/girafe.md)

## Examples

``` r
# add interactive colourbar guide to a ggplot -------
library(ggplot2)
library(ggiraph)

df <- expand.grid(x = 0:5, y = 0:5)
df$z <- runif(nrow(df))

p <- ggplot(df, aes(x, y, fill = z, tooltip = "tooltip")) +
  geom_raster_interactive()

# add an interactive scale (guide is colourbar)
p1 <- p +
  scale_fill_gradient_interactive(
    data_id = "colourbar",
    onclick = "alert(\"colourbar\")",
    tooltip = "colourbar"
  )
x <- girafe(ggobj = p1)
if (interactive()) {
  print(x)
}

# make the legend title interactive
p2 <- p +
  scale_fill_gradient_interactive(
    data_id = "colourbar",
    onclick = "alert(\"colourbar\")",
    tooltip = "colourbar",
    name = label_interactive(
      "z",
      data_id = "colourbar",
      onclick = "alert(\"colourbar\")",
      tooltip = "colourbar"
    )
  )
x <- girafe(ggobj = p2)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}

# make the legend labels interactive
p3 <- p +
  scale_fill_gradient_interactive(
    data_id = "colourbar",
    onclick = "alert(\"colourbar\")",
    tooltip = "colourbar",
    name = label_interactive(
      "z",
      data_id = "colourbar",
      onclick = "alert(\"colourbar\")",
      tooltip = "colourbar"
    ),
    labels = function(breaks) {
      lapply(breaks, function(abreak) {
        label_interactive(
          as.character(abreak),
          data_id = paste0("colourbar", abreak),
          onclick = "alert(\"colourbar\")",
          tooltip = paste0("colourbar", abreak)
        )
      })
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
  scale_fill_gradient_interactive(
    data_id = "colourbar",
    onclick = "alert(\"colourbar\")",
    tooltip = "colourbar",
    guide = guide_colourbar_interactive(
      title.theme = element_text_interactive(
        size = 8,
        data_id = "colourbar",
        onclick = "alert(\"colourbar\")",
        tooltip = "colourbar"
      ),
      label.theme = element_text_interactive(
        size = 8,
        data_id = "colourbar",
        onclick = "alert(\"colourbar\")",
        tooltip = "colourbar"
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

# make the legend background interactive
p5 <- p4 +
  theme(
    legend.background = element_rect_interactive(
      data_id = "colourbar",
      onclick = "alert(\"colourbar\")",
      tooltip = "colourbar"
    )
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
