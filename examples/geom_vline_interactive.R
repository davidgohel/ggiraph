library(ggplot2)


g1 <- ggplot(diamonds, aes(carat)) +
  geom_histogram()

gg_vline1 <- g1 + geom_vline_interactive(
  aes(xintercept = mean(carat),
      tooltip = round(mean(carat), 2),
      data_id = carat))

dataset <- data.frame(x = rnorm(100))

dataset$clickjs <- rep(paste0("alert(\"",
                              round(mean(dataset$x), 2), "\")"), 100)

g2 <- ggplot(dataset, aes(x)) +
  geom_density(fill = "#000000", alpha = 0.7)
gg_vline2 <- g2 + geom_vline_interactive(
  aes(xintercept = mean(x), tooltip = round(mean(x), 2),
      data_id = x, onclick = clickjs), color = "white")

ggiraph(code = print(gg_vline1))
ggiraph(code = print(gg_vline2),
        hover_css = "cursor:pointer;fill:orange;stroke:orange;")
