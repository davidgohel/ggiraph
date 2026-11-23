# geom_density_2d_interactive ----
test_that("geom_density_2d_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_density_2d_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_density2d_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_density_2d_filled_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_density2d_filled_interactive"))
})
