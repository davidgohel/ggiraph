library(ggplot2)
library(ggiraph)

p <- ggplot(diamonds, aes(carat)) +
  geom_histogram_interactive(
    bins = 30,
    aes(tooltip = after_stat(count), group = 1L)
  )
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

p <- ggplot(diamonds, aes(price, colour = cut, tooltip = cut, data_id = cut)) +
  geom_freqpoly_interactive(binwidth = 500)
x <- girafe(ggobj = p)
x <- girafe_options(x = x, opts_hover(css = "stroke-width:3px;"))
if (interactive()) {
  print(x)
}
