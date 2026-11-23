# find_interactive_class ----
test_that("find_interactive_class", {
  expect_s3_class(ggiraph:::find_interactive_class("histogram"), "Geom")
  expect_s3_class(ggiraph:::find_interactive_class(GeomBoxplot), "Geom")
  expect_error(ggiraph:::find_interactive_class(FALSE))
  expect_error(ggiraph:::find_interactive_class("foo"))
})

# layer_interactive argument interactive_geom ----
test_that("layer_interactive argument interactive_geom", {
  result <- ggiraph:::layer_interactive(geom_count, interactive_geom = GeomInteractivePoint)
  expect_identical(result$geom, GeomInteractivePoint)
})
