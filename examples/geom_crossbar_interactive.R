library(ggplot2)
library(ggiraph)

# Create a simple example dataset
df <- data.frame(
  trt = factor(c(1, 1, 2, 2)),
  resp = c(1, 5, 3, 4),
  group = factor(c(1, 2, 1, 2)),
  upper = c(1.1, 5.3, 3.3, 4.2),
  lower = c(0.8, 4.6, 2.4, 3.6)
)

p <- ggplot(df, aes(trt, resp, colour = group))


g <- p +
  geom_linerange_interactive(aes(ymin = lower, ymax = upper, tooltip = group))
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

g <- p +
  geom_pointrange_interactive(aes(ymin = lower, ymax = upper, tooltip = group))
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

g <- p +
  geom_crossbar_interactive(
    aes(ymin = lower, ymax = upper, tooltip = group),
    width = 0.2
  )
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

g <- p +
  geom_errorbar_interactive(
    aes(ymin = lower, ymax = upper, tooltip = group),
    width = 0.2
  )
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}
