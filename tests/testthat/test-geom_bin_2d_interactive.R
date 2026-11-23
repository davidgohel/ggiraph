# geom_bin_2d_interactive ----
test_that("geom_bin_2d_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_bin_2d_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_bin2d_interactive"))
})
