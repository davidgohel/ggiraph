library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()

dataset <- mtcars
dataset$carname <- row.names(mtcars)

gg_point <- ggplot(
  data = dataset,
  mapping = aes(
    x = wt, y = qsec, color = disp,
    tooltip = carname, data_id = carname
  )
) +
  geom_point_interactive(hover_nearest = TRUE, size = 11/.pt) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

x <- girafe(
  ggobj = gg_point,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)

x
