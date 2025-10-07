library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()

## the data
dataset = mtcars
dataset$label = row.names(mtcars)

dataset$tooltip = paste0(
  "cyl: ",
  dataset$cyl,
  "<br/>",
  "gear: ",
  dataset$gear,
  "<br/>",
  "carb: ",
  dataset$carb
)

## the plot
gg_text = ggplot(
  dataset,
  aes(
    x = mpg,
    y = wt,
    label = label,
    color = qsec,
    tooltip = tooltip,
    data_id = label
  )
) +
  geom_text_interactive(check_overlap = TRUE, family = "Liberation Sans") +
  coord_cartesian(xlim = c(0, 50)) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

## display the plot
x <- girafe(
  ggobj = gg_text,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
x <- girafe_options(x = x, opts_hover(css = "fill:#FF4C3B;font-style:italic;"))
if (interactive()) {
  print(x)
}
