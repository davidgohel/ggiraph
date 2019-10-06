library(ggplot2)
library(ggiraph)

p <- ggplot(diamonds, aes(carat)) +
  geom_density_interactive(tooltip="density", data_id="density")
x <- girafe(ggobj = p)
x <- girafe_options(x = x,
                    opts_hover(css = "stroke:orange;stroke-width:3px;") )
if( interactive() ) print(x)

p <- ggplot(diamonds, aes(depth, fill = cut, colour = cut)) +
  geom_density_interactive(aes(tooltip=cut, data_id=cut), alpha = 0.1) +
  xlim(55, 70)
x <- girafe(ggobj = p)
x <- girafe_options(x = x,
                    opts_hover(css = "stroke:yellow;stroke-width:3px;fill-opacity:0.8;") )
if( interactive() ) print(x)


p <- ggplot(diamonds, aes(carat, fill = cut)) +
  geom_density_interactive(aes(tooltip=cut, data_id=cut), position = "stack")
x <- girafe(ggobj = p)
if( interactive() ) print(x)

p <- ggplot(diamonds, aes(carat, stat(count), fill = cut)) +
  geom_density_interactive(aes(tooltip=cut, data_id=cut), position = "fill")
x <- girafe(ggobj = p)
if( interactive() ) print(x)
