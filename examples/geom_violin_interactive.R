library(ggplot2)
library(ggiraph)

p <- ggplot(mtcars, aes(factor(cyl), mpg)) +
  geom_violin_interactive(aes(fill = cyl, tooltip = cyl))
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

# Show quartiles
p2 <- ggplot(mtcars, aes(factor(cyl), mpg)) +
  geom_violin_interactive(
    aes(tooltip = after_stat(density)),
    draw_quantiles = c(0.25, 0.5, 0.75)
  )
x2 <- girafe(ggobj = p2)
if (interactive()) {
  print(x2)
}
