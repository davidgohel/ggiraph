library(ggplot2)
library(ggiraph)

p <- ggplot(mtcars, aes(x = mpg, fill = factor(cyl))) +
  geom_dotplot_interactive(
    aes(tooltip = row.names(mtcars)),
    stackgroups = TRUE, binwidth = 1, method = "histodot"
  )

x <- girafe(ggobj = p)
if( interactive() ) print(x)

gg_point = ggplot(
  data = mtcars,
  mapping = aes(
    x = factor(vs), fill = factor(cyl), y = mpg,
    tooltip = row.names(mtcars))) +
  geom_dotplot_interactive(binaxis = "y",
    stackdir = "center", position = "dodge")

x <- girafe(ggobj = gg_point)
if( interactive() ) print(x)
