# geom_rect_interactive ----
test_that("geom_rect_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_rect_interactive"))
})
test_that("geom_rect_interactive draws every rectangle with its tooltip", {
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
  expect_equal(tooltips, sort(df$t), info = "polygon tooltips are set")
})

rects <- data.frame(xmin = c(0, 2), xmax = c(1, 3), ymin = 0, ymax = 1, g = c("a", "b"))

test_that("geom_rect_interactive draws as geom_rect in polar coordinates", {
  base <- ggplot(rects, aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)) +
    coord_polar()
  expected <- svg_shapes(base + geom_rect(), "polygon")
  shapes <- svg_shapes(base + geom_rect_interactive(aes(data_id = g)), "polygon")
  expect_equal(shapes$points, expected$points)
  expect_equal(shapes$id, c("a", "b"))
})

test_that("geom_rect_interactive accepts a gradient fill", {
  shapes <- svg_shapes(
    ggplot(rects) +
      geom_rect_interactive(
        aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, data_id = g),
        fill = linearGradient(c("red", "blue"))
      ),
    "rect"
  )
  shapes <- shapes[!is.na(shapes$id), ]
  expect_true(all(startsWith(shapes$fill, "url(#")))
  expect_equal(shapes$id, c("a", "b"))
})
