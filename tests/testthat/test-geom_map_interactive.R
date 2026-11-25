skip_if_not_installed("maps")

# geom_map_interactive ----
test_that("geom_map_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_map_interactive"))
})

map_ids <- factor(c("a", "b"))
map_values <- data.frame(id = map_ids, value = c(3, 3.1))
map_positions <- data.frame(
  id = rep(map_ids, each = 4),
  x = c(2, 1, 1.1, 2.2, 1, 0, 0.3, 1.1),
  y = c(-0.5, 0, 1, 0.5, 0, 0.5, 1.5, 1)
)

test_that("geom_map_interactive draws as geom_map, in cartesian and polar coordinates", {
  base <- ggplot(map_values, aes(fill = value)) + expand_limits(map_positions)
  for (coords in list(coord_cartesian(), coord_polar())) {
    expected <- svg_shapes(
      base + geom_map(aes(map_id = id), map = map_positions) + coords,
      "polygon"
    )
    shapes <- svg_shapes(
      base + geom_map_interactive(aes(map_id = id, data_id = id), map = map_positions) + coords,
      "polygon"
    )
    expect_equal(shapes$points, expected$points)
    expect_equal(shapes$id, c("a", "b"))
  }
})

test_that("geom_map_interactive accepts a gradient fill", {
  shapes <- svg_shapes(
    ggplot(map_values) + expand_limits(map_positions) +
      geom_map_interactive(
        aes(map_id = id, data_id = id),
        map = map_positions,
        fill = linearGradient(c("red", "blue"))
      ),
    "polygon"
  )
  expect_true(all(startsWith(shapes$fill, "url(#")))
  expect_equal(shapes$id, c("a", "b"))
})

test_that("each shape of the map takes the row of its region", {
  sq <- function(x0, y0, id, group) data.frame(long = x0 + c(0, 1, 1, 0), lat = y0 + c(0, 0, 1, 1), id = id, group = group)
  # r1 has two shapes, r3 is not in the data, r4 is not in the map
  map <- rbind(sq(0, 0, "r1", "r1.1"), sq(2, 0, "r1", "r1.2"), sq(0, 2, "r2", "r2.1"), sq(2, 2, "r3", "r3.1"))
  dat <- data.frame(region = c("r2", "r1", "r4"))
  for (coord in list(coord_cartesian(), coord_polar())) {
    doc <- dsvg_plot(ggplot(dat, aes(map_id = region)) + coord +
      geom_map_interactive(aes(data_id = region), map = map) +
      expand_limits(x = c(0, 3), y = c(0, 3)))
    expect_equal(xml_attr(xml_find_all(doc, ".//polygon[@data-id]"), "data-id"), c("r1", "r1", "r2"))
  }
})
