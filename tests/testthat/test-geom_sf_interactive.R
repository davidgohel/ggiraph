skip_if_not_installed("sf")

# geom_sf_interactive ----
test_that("geom_sf_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_sf_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_sf_text_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_sf_label_interactive"))
})

sf_shapes <- function(p) {
  doc <- dsvg_plot(p + theme_void())
  nodes <- xml_find_all(doc, ".//polygon|.//polyline|.//path|.//circle|.//line|.//text")
  attr <- function(name) xml_attr(nodes, name)
  data.frame(
    geometry = paste(
      xml_name(nodes), attr("points"), attr("d"), attr("cx"), attr("cy"),
      attr("x"), attr("y"), xml_text(nodes)
    ),
    id = attr("data-id")
  )
}

expect_same_sf <- function(layer, layer_interactive, data, ids) {
  expected <- sf_shapes(ggplot(data) + layer)
  result <- sf_shapes(ggplot(data) + layer_interactive)
  expect_equal(result$geometry, expected$geometry)
  expect_equal(result$id[!is.na(result$id)], ids)
}

sf_lines <- sf::st_sf(
  id = c("l1", "l2"),
  geometry = sf::st_sfc(
    sf::st_linestring(rbind(c(0, 0), c(1, 1))),
    sf::st_linestring(rbind(c(1, 0), c(2, 1)))
  )
)

test_that("geometries are drawn as in ggplot2, with the attributes of their row", {
  nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)[1:3, ]
  expect_same_sf(
    geom_sf(), geom_sf_interactive(aes(data_id = NAME)),
    nc, c("Ashe", "Alleghany", "Surry")
  )
  points <- sf::st_sf(
    id = c("p1", "p2"),
    geometry = sf::st_sfc(sf::st_point(c(0, 0)), sf::st_point(c(1, 1)))
  )
  expect_same_sf(geom_sf(), geom_sf_interactive(aes(data_id = id)), points, c("p1", "p2"))
  expect_same_sf(geom_sf(), geom_sf_interactive(aes(data_id = id)), sf_lines, c("l1", "l2"))
  expect_same_sf(
    geom_sf_text(aes(label = id)),
    geom_sf_text_interactive(aes(label = id, data_id = id)),
    points, c("p1", "p2")
  )
})

test_that("lines can have arrows", {
  # the arrow head is drawn as an element of its own, with the line attributes
  expect_same_sf(
    geom_sf(arrow = arrow()),
    geom_sf_interactive(aes(data_id = id), arrow = arrow()),
    sf_lines, c("l1", "l1", "l2", "l2")
  )
})

test_that("arrows are not drawn on a layer mixing geometries, as in ggplot2", {
  # 'sf' ignores the arrows when the layer is not made of lines only
  mixed <- sf::st_sf(
    id = paste0("g", 1:7),
    lt = c(rep("solid", 6), "blank"),
    geometry = sf::st_sfc(
      sf::st_point(c(0, 0)),
      sf::st_linestring(rbind(c(0, 1), c(1, 2), c(2, 1))),
      sf::st_multilinestring(list(rbind(c(3, 0), c(4, 1)), rbind(c(3, 2), c(4, 3)))),
      sf::st_polygon(list(rbind(c(5, 0), c(6, 0), c(6, 1), c(5, 0)))),
      sf::st_geometrycollection(list(
        sf::st_point(c(7, 0)),
        sf::st_linestring(rbind(c(7, 1), c(8, 2)))
      )),
      sf::st_multipoint(rbind(c(9, 0), c(9, 1))),
      sf::st_linestring(rbind(c(10, 0), c(11, 1)))
    )
  )
  both <- arrow(ends = "both")
  expect_same_sf(
    geom_sf(arrow = both),
    geom_sf_interactive(aes(data_id = id), arrow = both),
    mixed, rep(mixed$id, c(1, 1, 2, 1, 2, 2, 1))
  )
  # a blank linetype draws nothing
  expect_same_sf(
    list(geom_sf(aes(linetype = lt), arrow = both), scale_linetype_identity()),
    list(geom_sf_interactive(aes(data_id = id, linetype = lt), arrow = both), scale_linetype_identity()),
    mixed, rep(mixed$id, c(1, 1, 2, 1, 2, 2, 0))
  )
  # lines and multilines keep their arrows, each head with its row
  lines <- mixed[c(2, 3, 7), ]
  expect_same_sf(
    geom_sf(arrow = both),
    geom_sf_interactive(aes(data_id = id), arrow = both),
    lines, rep(lines$id, c(3, 6, 3))
  )
})

test_that("geometry collections are drawn with other geometries", {
  mixed <- sf::st_sf(
    id = c("g1", "g2"),
    geometry = sf::st_sfc(
      sf::st_geometrycollection(list(
        sf::st_point(c(1, 1)),
        sf::st_linestring(rbind(c(0, 1), c(1, 0)))
      )),
      sf::st_point(c(2, 2))
    )
  )
  expect_same_sf(
    geom_sf(), geom_sf_interactive(aes(data_id = id)),
    mixed, c("g1", "g1", "g2")
  )
})
