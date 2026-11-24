# annotation_raster_interactive ----
test_that("annotation_raster_interactive", {
  eval(test_annot_layer, envir = list(name = "annotation_raster_interactive"))
})

test_that("the annotation image carries the attributes", {
  img <- matrix(hcl(seq(0, 360, length.out = 12), 80, 70), nrow = 3)
  base <- ggplot(mtcars, aes(wt, mpg)) + geom_blank()
  expected <- svg_area_shapes(base + annotation_raster(img, 2, 4, 15, 25))
  result <- svg_area_shapes(
    base + annotation_raster_interactive(img, 2, 4, 15, 25, tooltip = "ann", data_id = "an")
  )
  expect_equal(result$geometry, expected$geometry)
  expect_equal(result$id, "an")
  expect_equal(result$title, "ann")
})
