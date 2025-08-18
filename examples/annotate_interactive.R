library(ggplot2)
library(ggiraph)

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
  )

x <- girafe(ggobj = gg, width_svg = 5, height_svg = 4)
if (interactive()) {
  print(x)
}
