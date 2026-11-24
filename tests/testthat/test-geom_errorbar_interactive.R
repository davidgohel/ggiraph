# geom_errorbar_interactive ----
test_that("geom_errorbar_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_errorbar_interactive"))
})

errorbar_data <- data.frame(
  trt = factor(c("a", "b")),
  resp = c(1, 5),
  lower = c(0.5, 4),
  upper = c(1.5, 6)
)

errorbar_polylines <- function(p) {
  doc <- dsvg_plot(p + theme_void())
  xml_find_all(doc, ".//polyline")
}

test_that("errorbars are drawn as in ggplot2, in both orientations", {
  vertical <- ggplot(errorbar_data, aes(trt, resp, ymin = lower, ymax = upper))
  horizontal <- ggplot(errorbar_data, aes(resp, trt, xmin = lower, xmax = upper))
  for (base in list(vertical, horizontal)) {
    expected <- errorbar_polylines(base + geom_errorbar())
    nodes <- errorbar_polylines(base + geom_errorbar_interactive(aes(data_id = trt)))
    expect_equal(xml_attr(nodes, "points"), xml_attr(expected, "points"))
  }
})

test_that("each errorbar carries the attributes of its row", {
  horizontal <- ggplot(errorbar_data, aes(resp, trt, xmin = lower, xmax = upper)) +
    geom_errorbar_interactive(aes(data_id = trt, tooltip = paste("tt", trt)))
  nodes <- errorbar_polylines(horizontal)
  # three lines per errorbar: two whiskers and the bar
  expect_equal(xml_attr(nodes, "data-id"), rep(c("a", "b"), each = 3))
  expect_equal(xml_attr(nodes, "title"), rep(c("tt a", "tt b"), each = 3))
})
