library(ggplot2)
library(ggiraph)
library(gdtools)

fonts <- font_set(sans = font_liberation("sans"))

dataset <- mtcars
dataset$carname <- row.names(mtcars)

gg_point <- ggplot(
  data = dataset,
  mapping = aes(
    x = wt,
    y = qsec,
    color = disp,
    tooltip = carname,
    data_id = carname
  )
) +
  geom_point_interactive(hover_nearest = TRUE, size = 11 / .pt) +
  theme_minimal(base_family = fonts$sans, base_size = 11)

x <- girafe(
  ggobj = gg_point,
  font_set = fonts
)

x
