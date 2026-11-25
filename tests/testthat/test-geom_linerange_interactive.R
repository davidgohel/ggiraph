# geom_linerange_interactive ----
test_that("geom_linerange_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_linerange_interactive"))
})

test_that("lines are drawn as in ggplot2, with their attributes", {
  expect_interval_geom(geom_linerange, geom_linerange_interactive, "line")
})

test_that("lines keep their attributes in polar coordinates", {
  p <- ggplot(interval_data, aes(trt, ymin = lower, ymax = upper)) +
    geom_linerange_interactive(aes(data_id = trt)) +
    coord_polar()
  doc <- dsvg_plot(p)
  expect_equal(
    xml_attr(xml_find_all(doc, ".//polyline[@data-id]"), "data-id"),
    c("a", "b", "c")
  )
})

test_that("a line removed by ggplot2 does not shift the attributes", {
  dat <- transform(interval_data, lt = c("solid", NA, "dashed"))
  p <- ggplot(dat, aes(trt, ymin = lower, ymax = upper, linetype = lt)) +
    geom_linerange_interactive(aes(data_id = trt))
  expect_warning(doc <- dsvg_plot(p), "Removed 1 row")
  expect_equal(xml_attr(xml_find_all(doc, ".//line[@data-id]"), "data-id"), c("a", "c"))
})
