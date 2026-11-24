# geom_raster_interactive ----
test_that("geom_raster_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_raster_interactive"))
})

test_that("the raster image carries the attributes", {
  dat <- expand.grid(x = 1:3, y = 1:2)
  dat$z <- 1:6
  base <- ggplot(dat, aes(x, y, fill = z))
  for (interpolate in c(FALSE, TRUE)) {
    expected <- svg_area_shapes(base + geom_raster(interpolate = interpolate))
    result <- svg_area_shapes(
      base + geom_raster_interactive(tooltip = "img", data_id = "r", interpolate = interpolate)
    )
    expect_equal(result$geometry, expected$geometry)
    expect_equal(result$id, "r")
    expect_equal(result$title, "img")
  }
})
