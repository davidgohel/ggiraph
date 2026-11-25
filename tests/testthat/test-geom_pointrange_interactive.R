# geom_pointrange_interactive ----
test_that("geom_pointrange_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_pointrange_interactive"))
})

test_that("lines and points are drawn as in ggplot2, with their attributes", {
  expect_interval_geom(geom_pointrange, geom_pointrange_interactive, c("line", "circle"))
})

test_that("lines and points keep their attributes in polar coordinates", {
  p <- ggplot(interval_data, aes(trt, resp, ymin = lower, ymax = upper)) +
    coord_polar()
  expected <- svg_line_shapes(p + geom_pointrange())
  doc <- dsvg_plot(p + theme_void() + geom_pointrange_interactive(aes(data_id = trt)))
  lines <- xml_find_all(doc, ".//polyline")
  expect_equal(paste(xml_name(lines), xml_attr(lines, "points")),
               gsub(" NA", "", sub(" [a-z]+$", "", expected$geometry)))
  expect_equal(xml_attr(lines, "data-id"), c("a", "b", "c"))
  expect_equal(xml_attr(xml_find_all(doc, ".//circle"), "data-id"), c("a", "b", "c"))
})

test_that("a line removed by ggplot2 does not shift the attributes", {
  dat <- transform(interval_data, lt = c("solid", NA, "dashed"))
  p <- ggplot(dat, aes(trt, resp, ymin = lower, ymax = upper, linetype = lt)) +
    geom_pointrange_interactive(aes(data_id = trt))
  expect_warning(doc <- dsvg_plot(p), "Removed 1 row")
  # the legend keys have no attributes
  expect_equal(xml_attr(xml_find_all(doc, ".//line[@data-id]"), "data-id"), c("a", "c"))
  expect_equal(xml_attr(xml_find_all(doc, ".//circle[@data-id]"), "data-id"), c("a", "b", "c"))
})
