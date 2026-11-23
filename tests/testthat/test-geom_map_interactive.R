skip_if_not_installed("maps")

# geom_map_interactive ----
test_that("geom_map_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_map_interactive"))
})
