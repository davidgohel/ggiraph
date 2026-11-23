skip_if_not_installed("hexbin")

# geom_hex_interactive ----
test_that("geom_hex_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_hex_interactive"))
})
