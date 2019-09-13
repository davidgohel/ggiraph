library(ggplot2)
library(ggiraph)

p <- ggplot(mpg,
  aes(x = class, y = hwy, tooltip = class)) +
  geom_boxplot_interactive()

x <- girafe(ggobj = p)
if( interactive() ) print(x)

p <- ggplot(mpg, aes(x = drv, y = hwy, tooltip = class, fill = class, data_id=class)) +
  geom_boxplot_interactive(outlier.colour = "red") +
  guides(fill = "none") + theme_minimal()

x <- girafe(ggobj = p)
if( interactive() ) print(x)
