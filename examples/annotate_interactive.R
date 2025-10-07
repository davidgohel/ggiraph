library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()

gg <- ggplot(mtcars, aes(x = disp, y = qsec)) +
  geom_point(size = 2) +
  annotate_interactive(
    "rect",
    xmin = 100,
    xmax = 400,
    fill = "red",
    data_id = "an_id",
    tooltip = "a tooltip",
    ymin = 18,
    ymax = 20,
    alpha = .5
  ) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

girafe(
  ggobj = gg,
  width_svg = 5,
  height_svg = 4,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)




