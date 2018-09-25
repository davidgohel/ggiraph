library(ggplot2)

p <- ggplot(mpg,
  aes(x = class, y = hwy, tooltip = class)) +
  geom_boxplot_interactive()

ggiraph(code = print(p))


p <- ggplot(mpg, aes(x = drv, y = hwy, tooltip = class, fill = class)) +
  geom_boxplot_interactive(outlier.colour = "red") +
  guides(fill = "none") + theme_minimal()

girafe(ggobj = p)
