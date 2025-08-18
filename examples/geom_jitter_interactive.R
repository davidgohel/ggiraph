library(ggplot2)
library(ggiraph)

gg_jitter <- ggplot(
  mpg,
  aes(cyl, hwy, tooltip = paste(manufacturer, model, year, trans, sep = "\n"))
) +
  geom_jitter_interactive()

x <- girafe(ggobj = gg_jitter)
if (interactive()) {
  print(x)
}
