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
x

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
x

# make the title and labels interactive
p3 <- p +
  scale_fill_viridis_c_interactive(
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
    guide = "bins",
    name = label_interactive("nlevel", data_id = "nlevel", tooltip = "nlevel"),
    labels = function(breaks) {
      label_interactive(
        as.character(breaks),
        data_id = as.character(breaks),
        onclick = paste0("alert(\"", as.character(breaks), "\")"),
        tooltip = as.character(breaks)
      )
    }
  )
x <- girafe(ggobj = p3)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
x
