# geom_pointrange_interactive ----
test_that("geom_pointrange_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_pointrange_interactive"))
})

test_that("lines and points are drawn as in ggplot2, with their attributes", {
  expect_interval_geom(geom_pointrange, geom_pointrange_interactive, c("line", "circle"))
})
