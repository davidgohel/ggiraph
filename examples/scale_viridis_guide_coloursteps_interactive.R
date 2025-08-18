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

# add interactive binned scale, by default the guide is colorsteps
p1 <- p +
  scale_fill_viridis_b_interactive(data_id = "nlevel", tooltip = "nlevel")
x <- girafe(ggobj = p1)
if (interactive()) {
  print(x)
}


# make the title and labels interactive
p2 <- p +
  scale_fill_viridis_b_interactive(
    data_id = "nlevel",
    tooltip = "nlevel",
    name = label_interactive("nlevel", data_id = "nlevel", tooltip = "nlevel"),
    labels = function(breaks) {
      l <- lapply(breaks, function(br) {
        label_interactive(
          as.character(br),
          data_id = as.character(br),
          onclick = paste0("alert(\"", as.character(br), "\")"),
          tooltip = as.character(br)
        )
      })
      l
    }
  )
x <- girafe(ggobj = p2)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}
