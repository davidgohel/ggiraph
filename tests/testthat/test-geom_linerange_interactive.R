# geom_linerange_interactive ----
test_that("geom_linerange_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_linerange_interactive"))
})

test_that("lines are drawn as in ggplot2, with their attributes", {
  expect_interval_geom(geom_linerange, geom_linerange_interactive, "line")
})
