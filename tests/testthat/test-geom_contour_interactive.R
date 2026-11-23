# geom_contour_interactive ----
test_that("geom_contour_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_contour_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_contour_filled_interactive"))
})
