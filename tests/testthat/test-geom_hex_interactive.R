skip_if_not_installed("hexbin")

# geom_hex_interactive ----
test_that("geom_hex_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_hex_interactive"))
})

test_that("each hexagon carries the attributes of its bin", {
  set.seed(1)
  dat <- data.frame(x = rnorm(200), y = rnorm(200))
  base <- ggplot(dat, aes(x, y))
  for (coord in list(coord_cartesian(), coord_polar())) {
    expected <- svg_area_shapes(base + geom_hex(bins = 5) + coord)
    layer <- geom_hex_interactive(
      aes(tooltip = after_stat(count), data_id = after_stat(count)),
      bins = 5
    )
    result <- svg_area_shapes(base + layer + coord)
    expect_equal(result$geometry, expected$geometry)
    counts <- layer_data(base + layer)$count
    expect_equal(result$id, as.character(counts))
    expect_equal(result$title, as.character(counts))
  }
})
