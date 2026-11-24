# geom_curve_interactive ----
test_that("geom_curve_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_curve_interactive"))
})

test_that("each curve and its arrow carry the attributes of their row", {
  dat <- data.frame(
    x = 1:3, y = c(1, 3, 2), xend = 2:4, yend = c(2, 1, 3),
    id = c("a", "b", "c")
  )
  shapes <- function(p) {
    doc <- dsvg_plot(p + theme_void())
    nodes <- xml_find_all(doc, ".//polyline|.//polygon")
    data.frame(
      tag = xml_name(nodes),
      points = xml_attr(nodes, "points"),
      id = xml_attr(nodes, "data-id"),
      title = xml_attr(nodes, "title")
    )
  }
  base <- ggplot(dat, aes(x, y, xend = xend, yend = yend))

  expected <- shapes(base + geom_curve(curvature = -.5))
  result <- shapes(base + geom_curve_interactive(
    aes(data_id = id, tooltip = paste("tt", id)),
    curvature = -.5
  ))
  expect_equal(result$points, expected$points)
  expect_equal(result$id, c("a", "b", "c"))
  expect_equal(result$title, c("tt a", "tt b", "tt c"))

  arrow_head <- arrow(type = "closed")
  expected <- shapes(base + geom_curve(arrow = arrow_head))
  result <- shapes(base + geom_curve_interactive(aes(data_id = id), arrow = arrow_head))
  expect_equal(result$points, expected$points)
  expect_equal(result$tag, rep(c("polyline", "polygon"), 3))
  expect_equal(result$id, rep(c("a", "b", "c"), each = 2))
})
