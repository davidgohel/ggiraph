skip_if_not_installed("sf")

# geom_sf_interactive ----
test_that("geom_sf_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_sf_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_sf_text_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_sf_label_interactive"))
})
