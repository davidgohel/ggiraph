library(ggplot2)
library(ggiraph)

df <- data.frame(
  trt = factor(c(1, 1, 2, 2)),
  resp = c(1, 5, 3, 4),
  group = factor(c(1, 2, 1, 2)),
  se = c(0.1, 0.3, 0.3, 0.2)
)

# Define the top and bottom of the errorbars

p <- ggplot(df, aes(resp, trt, colour = group))
g <- p +
  geom_point() +
  geom_errorbarh_interactive(aes(
    xmax = resp + se,
    xmin = resp - se,
    tooltip = group
  ))
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

g <- p +
  geom_point() +
  geom_errorbarh_interactive(aes(
    xmax = resp + se,
    xmin = resp - se,
    height = .2,
    tooltip = group
  ))
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}
