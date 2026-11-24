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

# extra_interactive_params ----
test_that("extra_interactive_params accept mapped and fixed values", {
  base <- ggplot(mtcars, aes(wt, mpg))
  doc <- dsvg_plot(
    base + geom_point_interactive(aes(foo = cyl), extra_interactive_params = "foo")
  )
  nodes <- xml_find_all(doc, ".//circle[@foo]")
  expect_length(nodes, nrow(mtcars))
  expect_setequal(xml_attr(nodes, "foo"), c("4", "6", "8"))

  doc <- dsvg_plot(
    base + geom_point_interactive(foo = "x", extra_interactive_params = "foo")
  )
  nodes <- xml_find_all(doc, ".//circle[@foo]")
  expect_length(nodes, nrow(mtcars))
  expect_equal(unique(xml_attr(nodes, "foo")), "x")
})

test_that("extra_interactive_params do not modify the shared geom", {
  before <- GeomInteractivePoint$default_aes
  layer <- geom_point_interactive(foo = "x", extra_interactive_params = "foo")
  expect_identical(GeomInteractivePoint$default_aes, before)
  expect_true("foo" %in% names(layer$geom$default_aes))
  expect_s3_class(layer$geom, "GeomInteractivePoint")
  expect_identical(layer$geom$super(), GeomInteractivePoint)
})
