library(ggplot2)
library(ggiraph)

counts <- as.data.frame(table(x = rpois(100, 5)))
counts$x <- as.numeric(as.character(counts$x))
counts$xlab <- paste0("bar", as.character(counts$x))

gg_segment_1 <- ggplot(
  data = counts,
  aes(x = x, y = Freq, yend = 0, xend = x, tooltip = xlab)
) +
  geom_segment_interactive(size = I(10))
x <- girafe(ggobj = gg_segment_1)
if (interactive()) {
  print(x)
}

dataset = data.frame(
  x = c(1, 2, 5, 6, 8),
  y = c(3, 6, 2, 8, 7),
  vx = c(1, 1.5, 0.8, 0.5, 1.3),
  vy = c(0.2, 1.3, 1.7, 0.8, 1.4),
  labs = paste0("Lab", 1:5)
)
dataset$clickjs = paste0("alert(\"", dataset$labs, "\")")

gg_segment_2 = ggplot() +
  geom_segment_interactive(
    data = dataset,
    mapping = aes(
      x = x,
      y = y,
      xend = x + vx,
      yend = y + vy,
      tooltip = labs,
      onclick = clickjs
    ),
    arrow = grid::arrow(length = grid::unit(0.03, "npc")),
    size = 2,
    color = "blue"
  ) +
  geom_point(
    data = dataset,
    mapping = aes(x = x, y = y),
    size = 4,
    shape = 21,
    fill = "white"
  )

x <- girafe(ggobj = gg_segment_2)
if (interactive()) {
  print(x)
}

df <- data.frame(x1 = 2.62, x2 = 3.57, y1 = 21.0, y2 = 15.0)
p <- ggplot(df, aes(x = x1, y = y1, xend = x2, yend = y2)) +
  geom_curve_interactive(aes(colour = "curve", tooltip = I("curve"))) +
  geom_segment_interactive(aes(colour = "segment", tooltip = I("segment")))

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}


p <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point(color = "grey50", alpha = 0.3, size = 2) +
  geom_hpline_interactive(
    data = iris[1:5, ],
    mapping = aes(tooltip = Species)
  ) +
  theme_bw()

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
