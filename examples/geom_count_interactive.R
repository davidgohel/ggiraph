library(ggplot2)
library(ggiraph)

p <- ggplot(mpg, aes(cty, hwy)) +
  geom_count_interactive(aes(tooltip=after_stat(n)))
x <- girafe(ggobj = p)
if( interactive() ) print(x)

p2 <- ggplot(diamonds, aes(x = cut, y = clarity)) +
  geom_count_interactive(aes(size = after_stat(prop),
                             tooltip = after_stat(round(prop, 3)), group = 1)) +
  scale_size_area(max_size = 10)
x <- girafe(ggobj = p2)
if (interactive()) print(x)
