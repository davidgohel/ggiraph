library(ggplot2)
library(ggiraph)

if (requireNamespace("dplyr", quietly = TRUE)) {
  g1 <- ggplot(economics, aes(x = date, y = unemploy)) +
    geom_point() +
    geom_line()

  gg_hline1 <- g1 +
    geom_hline_interactive(
      aes(yintercept = mean(unemploy), tooltip = round(mean(unemploy), 2)),
      linewidth = 3
    )
  x <- girafe(ggobj = gg_hline1)
  if (interactive()) print(x)
}

dataset <- data.frame(
  x = c(1, 2, 5, 6, 8),
  y = c(3, 6, 2, 8, 7),
  vx = c(1, 1.5, 0.8, 0.5, 1.3),
  vy = c(0.2, 1.3, 1.7, 0.8, 1.4),
  year = c(2014, 2015, 2016, 2017, 2018)
)

dataset$clickjs <- rep(paste0("alert(\"", mean(dataset$y), "\")"), 5)


g2 <- ggplot(dataset, aes(x = year, y = y)) +
  geom_point() +
  geom_line()

gg_hline2 <- g2 +
  geom_hline_interactive(
    aes(
      yintercept = mean(y),
      tooltip = round(mean(y), 2),
      data_id = y,
      onclick = clickjs
    )
  )

x <- girafe(ggobj = gg_hline2)
if (interactive()) {
  print(x)
}
