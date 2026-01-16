library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()

p <- ggplot(mtcars, aes(wt, mpg, label = rownames(mtcars))) +
  geom_label_interactive(
    aes(
      tooltip = paste(rownames(mtcars), mpg, sep = "\n")
    ),
    family = "Liberation Sans"
  ) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)
x <- girafe(
  ggobj = p,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}


p <- ggplot(mtcars, aes(wt, mpg, label = rownames(mtcars))) +
  geom_label_interactive(
    aes(fill = factor(cyl), tooltip = paste(rownames(mtcars), mpg, sep = "\n")),
    colour = "white",
    fontface = "bold",
    family = "Liberation Sans"
  ) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)
x <- girafe(
  ggobj = p,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}
