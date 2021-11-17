library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# geom_rect_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_rect_interactive"))
}
{
  df <- data.frame(
    x = rep(c(2, 5, 7, 9, 12), 2),
    y = rep(c(1, 2), each = 5),
    z = factor(rep(1:5, each = 2)),
    w = rep(diff(c(0, 4, 6, 8, 10, 14)), 2),
    t = as.character(seq_len(10))
  )
  doc <- dsvg_plot(
    ggplot(df, aes(xmin = x - w / 2, xmax = x + w / 2, ymin = y, ymax = y + 1)) +
      geom_rect_interactive(
        aes(tooltip = t),
        info = "geom_rect_interactive",
        extra_interactive_params = "info"
      ) +
      coord_polar()
  )
  nodes <- xml_find_all(doc, ".//polygon[@info]")
  expect_equal(length(nodes), nrow(df), info = "all polygons are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(df$t), "polygon tooltips are set")
}
