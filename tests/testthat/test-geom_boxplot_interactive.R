# geom_boxplot_interactive ----
test_that("geom_boxplot_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_boxplot_interactive"))
})

boxplot_data <- data.frame(
  g = rep(c("a", "b"), each = 7),
  v = c(10, 11, 12, 13, 14, 15, 40, 20, 21, 22, 23, 24, 25, 1),
  lab = paste0("p", 1:14)
)

test_that("boxes, whiskers and outliers are drawn as in ggplot2", {
  vertical <- ggplot(boxplot_data, aes(g, v))
  horizontal <- ggplot(boxplot_data, aes(v, g))
  for (base in list(vertical, horizontal)) {
    for (notch in c(FALSE, TRUE)) {
      expected <- suppressMessages(list(
        svg_shapes(base + geom_boxplot(notch = notch), "polygon"),
        svg_lines_circles(base + geom_boxplot(notch = notch))
      ))
      result <- suppressMessages(list(
        svg_shapes(base + geom_boxplot_interactive(aes(data_id = g), notch = notch), "polygon"),
        svg_lines_circles(base + geom_boxplot_interactive(aes(data_id = g), notch = notch))
      ))
      expect_equal(result[[1]]$points, expected[[1]]$points)
      expect_equal(result[[2]]$geometry, expected[[2]]$geometry)
      # each box carries the id of its group
      expect_equal(result[[1]]$id, c("a", "b"))
    }
  }
})

test_that("staples are drawn as in ggplot2, with the attributes of the box", {
  for (base in list(ggplot(boxplot_data, aes(g, v)), ggplot(boxplot_data, aes(v, g)))) {
    expected <- svg_lines_circles(base + geom_boxplot(staplewidth = .5))
    result <- svg_lines_circles(
      base + geom_boxplot_interactive(aes(data_id = g), staplewidth = .5)
    )
    expect_equal(result$geometry, expected$geometry)
    lines <- result[result$tag == "line", ]
    expect_false(anyNA(lines$id))
  }
})

test_that("outliers carry their own attributes, in both orientations", {
  vertical <- ggplot(boxplot_data, aes(g, v, group = g))
  horizontal <- ggplot(boxplot_data, aes(v, g, group = g))
  for (base in list(vertical, horizontal)) {
    shapes <- svg_lines_circles(
      base + geom_boxplot_interactive(
        aes(data_id = g, outlier.data_id = lab, outlier.tooltip = paste("tt", lab))
      )
    )
    outliers <- shapes[shapes$tag == "circle", ]
    expect_equal(outliers$id, c("p7", "p14"))
    expect_equal(outliers$title, c("tt p7", "tt p14"))
  }
})

test_that("quantile.type is used to compute the statistics", {
  base <- ggplot(boxplot_data, aes(g, v))
  expected <- layer_data(base + geom_boxplot(quantile.type = 1))
  result <- layer_data(base + geom_boxplot_interactive(quantile.type = 1))
  expect_equal(result$lower, expected$lower)
  expect_equal(result$upper, expected$upper)
})

test_that("an aesthetic varying within a group is dropped with a warning", {
  dat <- data.frame(g = rep(c("a", "b"), each = 5), v = 1:10, z = 1:10)
  p <- ggplot(dat, aes(g, v, colour = z)) + geom_boxplot_interactive(aes(data_id = g))
  expect_warning(doc <- dsvg_plot(p), "dropped during statistical transformation")
  expect_length(xml_find_all(doc, ".//polygon[@data-id]"), 2)
})
