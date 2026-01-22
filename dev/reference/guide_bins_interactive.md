# Create interactive bins guide

The guide is based on
[`ggplot2::guide_bins()`](https://ggplot2.tidyverse.org/reference/guide_bins.html).
See the documentation for that function for more details.

## Usage

``` r
guide_bins_interactive(...)
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
`guide_bins_interactive()`,
[`guide_colourbar_interactive()`](https://davidgohel.github.io/ggiraph/dev/reference/guide_colourbar_interactive.md)
or
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
# add interactive bins guide to a ggplot -------
library(ggplot2)
library(ggiraph)

set.seed(4393)
dsmall <- diamonds[sample(nrow(diamonds), 1000), ]
p <- ggplot(dsmall, aes(x, y)) +
  stat_density_2d(
    aes(
      fill = after_stat(nlevel),
      tooltip = paste("nlevel:", after_stat(nlevel))
    ),
    geom = "interactive_polygon"
  ) +
  facet_grid(. ~ cut)

# add interactive binned scale and guide
p1 <- p +
  scale_fill_viridis_b_interactive(
    data_id = "nlevel",
    tooltip = "nlevel",
    guide = "bins"
  )
x <- girafe(ggobj = p1)
if (interactive()) {
  print(x)
}

# set the keys separately
p2 <- p +
  scale_fill_viridis_b_interactive(
    data_id = function(breaks) {
      sapply(seq_along(breaks), function(i) {
        if (i < length(breaks)) {
          paste(
            min(breaks[i], breaks[i + 1], na.rm = TRUE),
            max(breaks[i], breaks[i + 1], na.rm = TRUE),
            sep = "-"
          )
        } else {
          NA_character_
        }
      })
    },
    tooltip = function(breaks) {
      sapply(seq_along(breaks), function(i) {
        if (i < length(breaks)) {
          paste(
            min(breaks[i], breaks[i + 1], na.rm = TRUE),
            max(breaks[i], breaks[i + 1], na.rm = TRUE),
            sep = "-"
          )
        } else {
          NA_character_
        }
      })
    },
    guide = "bins"
  )
x <- girafe(ggobj = p2)
if (interactive()) {
  print(x)
}

# # make the title and labels interactive
# p3 <- p +
#   scale_fill_viridis_c_interactive(
#     data_id = function(breaks) {
#       sapply(seq_along(breaks), function(i) {
#         if (i < length(breaks)) {
#           paste(
#             min(breaks[i], breaks[i + 1], na.rm = TRUE),
#             max(breaks[i], breaks[i + 1], na.rm = TRUE),
#             sep = "-"
#           )
#         } else {
#           NA_character_
#         }
#       })
#     },
#     tooltip = function(breaks) {
#       sapply(seq_along(breaks), function(i) {
#         if (i < length(breaks)) {
#           paste(
#             min(breaks[i], breaks[i + 1], na.rm = TRUE),
#             max(breaks[i], breaks[i + 1], na.rm = TRUE),
#             sep = "-"
#           )
#         } else {
#           NA_character_
#         }
#       })
#     },
#     guide = "bins",
#     name = label_interactive("nlevel", data_id = "nlevel", tooltip = "nlevel"),
#     labels = function(breaks) {
#       label_interactive(
#         as.character(breaks),
#         data_id = as.character(breaks),
#         onclick = paste0("alert(\"", as.character(breaks), "\")"),
#         tooltip = as.character(breaks)
#       )
#     }
#   )
# x <- girafe(ggobj = p3)
# x <- girafe_options(
#   x,
#   opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
# )
# if (interactive()) {
#   print(x)
# }
```
