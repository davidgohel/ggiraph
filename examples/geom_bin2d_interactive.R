library(ggplot2)
library(ggiraph)

p <- ggplot(diamonds, aes(x, y, fill = cut)) +
  xlim(4, 10) +
  ylim(4, 10) +
  geom_bin2d_interactive(aes(tooltip = cut), bins = 30)

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
