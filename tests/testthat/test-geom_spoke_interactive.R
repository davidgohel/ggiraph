# geom_spoke_interactive ----
test_that("geom_spoke_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_spoke_interactive"))
})

test_that("each spoke and its arrow carry the attributes of their row", {
  dat <- data.frame(
    x = 1:3, y = 1:3, angle = c(0, pi / 4, pi / 2),
    id = c("a", "b", "c")
  )
  base <- ggplot(dat, aes(x, y, angle = angle, radius = 1))
  for (coord in list(coord_cartesian(), coord_polar())) {
    expected <- svg_line_shapes(base + geom_spoke() + coord)
    result <- svg_line_shapes(base + geom_spoke_interactive(aes(data_id = id)) + coord)
    expect_equal(result$geometry, expected$geometry)
    expect_equal(result$id, c("a", "b", "c"))
  }
  expected <- svg_line_shapes(base + geom_spoke(arrow = arrow()))
  result <- svg_line_shapes(base + geom_spoke_interactive(aes(data_id = id), arrow = arrow()))
  expect_equal(result$geometry, expected$geometry)
  # the arrow head is drawn as an element of its own
  expect_equal(result$id, rep(c("a", "b", "c"), each = 2))
})
