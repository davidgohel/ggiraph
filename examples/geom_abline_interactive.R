library(ggplot2)
library(ggiraph)

p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
g <- p + geom_abline_interactive(intercept = 20, tooltip = 20)
x <- girafe(ggobj = g)
if (interactive()) {
  print(x)
}

l <- coef(lm(mpg ~ wt, data = mtcars))
g <- p +
  geom_abline_interactive(
    intercept = l[[1]],
    slope = l[[2]],
    tooltip = paste("intercept:", l[[1]], "\nslope:", l[[2]]),
    data_id = "abline"
  )
x <- girafe(ggobj = g)
x <- girafe_options(
  x = x,
  opts_hover(css = "cursor:pointer;fill:orange;stroke:orange;")
)
if (interactive()) {
  print(x)
}
