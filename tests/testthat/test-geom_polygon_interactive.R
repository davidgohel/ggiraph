# geom_polygon_interactive ----
test_that("geom_polygon_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_polygon_interactive"))
})

triangles <- data.frame(
  x = c(0, 1, .5, 1, 2, 1.5),
  y = c(0, 0, 1, 0, 0, 1),
  g = rep(c("a", "b"), each = 3)
)

test_that("geom_polygon_interactive draws as geom_polygon, in cartesian and polar coordinates", {
  base <- ggplot(triangles, aes(x, y, group = g))
  for (coords in list(coord_cartesian(), coord_polar())) {
    expected <- svg_shapes(base + geom_polygon() + coords, "polygon")
    shapes <- svg_shapes(base + geom_polygon_interactive(aes(data_id = g)) + coords, "polygon")
    expect_equal(shapes$points, expected$points)
    expect_equal(shapes$id, c("a", "b"))
  }
})

test_that("geom_polygon_interactive accepts a gradient fill", {
  shapes <- svg_shapes(
    ggplot(triangles, aes(x, y, group = g)) +
      geom_polygon_interactive(aes(data_id = g), fill = linearGradient(c("red", "blue"))),
    "polygon"
  )
  expect_true(all(startsWith(shapes$fill, "url(#")))
  expect_equal(shapes$id, c("a", "b"))
})

test_that("geom_polygon_interactive draws polygons with holes as geom_polygon", {
  square <- data.frame(x = c(0, 4, 4, 0), y = c(0, 0, 4, 4))
  hole <- data.frame(x = c(1, 3, 3, 1), y = c(1, 1, 3, 3))
  holed <- rbind(
    cbind(rbind(square, hole), subgroup = rep(1:2, each = 4), g = "a"),
    cbind(rbind(square + 5, hole + 5), subgroup = rep(1:2, each = 4), g = "b")
  )
  base <- ggplot(holed, aes(x, y, group = g, subgroup = subgroup)) + theme_void()
  path_d <- function(p) {
    nodes <- xml_find_all(dsvg_plot(p), ".//path")
    data.frame(d = xml_attr(nodes, "d"), id = xml_attr(nodes, "data-id"))
  }
  for (coords in list(coord_cartesian(), coord_polar())) {
    expected <- path_d(base + geom_polygon() + coords)
    shapes <- path_d(base + geom_polygon_interactive(aes(data_id = g)) + coords)
    expect_equal(shapes$d, expected$d)
    expect_equal(shapes$id, c("a", "b"))
  }
})

test_that("polygons with holes keep the attributes of their group", {
  sq <- function(x0, y0, s, g, sub) data.frame(x = x0 + c(0, s, s, 0), y = y0 + c(0, 0, s, s), g = g, sub = sub)
  holes <- rbind(sq(0, 0, 4, "A", 1), sq(1, 1, 2, "A", 2), sq(5, 0, 2, "B", 1))
  for (coord in list(coord_cartesian(), coord_polar())) {
    doc <- dsvg_plot(ggplot(holes, aes(x, y, group = g, subgroup = sub)) + coord +
      geom_polygon_interactive(aes(data_id = g)))
    expect_equal(xml_attr(xml_find_all(doc, ".//path[@data-id]"), "data-id"), c("A", "B"))
  }
})

test_that("a polygon cut by a missing point keeps its attributes on each piece", {
  d <- data.frame(
    x = c(0, 1, 1, NA, 2, 3, 3, 4, 5, 5),
    y = c(0, 0, 1, NA, 0, 0, 1, 0, 0, 1),
    g = rep(c("a", "b"), c(7, 3))
  )
  for (lt in c("solid", "blank")) {
    p <- ggplot(d, aes(x, y, group = g, fill = g, data_id = g)) +
      geom_polygon_interactive(linetype = lt)
    expect_no_warning(doc <- dsvg_plot(p))
    nodes <- xml_find_all(doc, ".//polygon[@data-id]")
    expect_equal(xml_attr(nodes, "data-id"), c("a", "a", "b"), info = lt)
    # each id is on the polygons of its colour
    expect_equal(length(unique(xml_attr(nodes, "fill")[1:2])), 1L, info = lt)
  }
})
