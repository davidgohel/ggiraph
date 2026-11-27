# geom_segment_interactive ----
test_that("geom_segment_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_segment_interactive"))
})

segment_data <- data.frame(
  x = 1:3,
  y = 1:3,
  xend = 2:4,
  yend = c(2, 3, 4),
  id = c("a", "b", "c")
)

segment_nodes <- function(p, xpath = "//line[@data-id]") {
  doc <- dsvg_plot(p)
  xml_find_all(doc, xpath)
}

test_that("each segment carries the attributes of its row", {
  p <- ggplot(segment_data, aes(x, y, xend = xend, yend = yend)) +
    geom_segment_interactive(aes(data_id = id, tooltip = paste("tt", id)))
  nodes <- segment_nodes(p)
  expect_equal(xml_attr(nodes, "data-id"), c("a", "b", "c"))
  expect_equal(xml_attr(nodes, "title"), c("tt a", "tt b", "tt c"))
})

test_that("a missing xend or yend is the start coordinate, as in ggplot2", {
  p <- ggplot(segment_data, aes(x, y, xend = xend)) +
    geom_segment_interactive(aes(data_id = id))
  nodes <- segment_nodes(p)
  expect_length(nodes, 3)
  expect_equal(xml_attr(nodes, "y1"), xml_attr(nodes, "y2"))
})

test_that("a missing interactive attribute does not remove the segment", {
  dat <- segment_data
  dat$tt <- c("a", NA, "c")
  p <- ggplot(dat, aes(x, y, xend = xend, yend = yend)) +
    geom_segment_interactive(aes(data_id = id, tooltip = tt))
  expect_no_warning(nodes <- segment_nodes(p))
  expect_equal(xml_attr(nodes, "data-id"), c("a", "b", "c"))
  expect_equal(xml_attr(nodes, "title")[c(1, 3)], c("a", "c"))
})

test_that("segments in non linear coordinates carry the attributes", {
  p <- ggplot(segment_data, aes(x, y, xend = xend, yend = yend)) +
    geom_segment_interactive(aes(data_id = id)) +
    coord_polar()
  nodes <- segment_nodes(p, "//polyline[@data-id]")
  expect_equal(xml_attr(nodes, "data-id"), c("a", "b", "c"))
})

test_that("segments and their arrow heads keep their attributes in polar coordinates", {
  sd <- data.frame(x = c(1, 2, 3), y = c(1, 3, 2), xend = c(2, 3, 4), yend = c(2, 1, 3))
  p <- ggplot(sd, aes(x, y, xend = xend, yend = yend)) +
    geom_segment_interactive(aes(data_id = c("a", "b", "c")), arrow = arrow(ends = "both")) +
    coord_polar()
  doc <- dsvg_plot(p)
  # one line and two arrow heads per segment
  expect_equal(
    xml_attr(xml_find_all(doc, ".//polyline[@data-id]"), "data-id"),
    rep(c("a", "b", "c"), each = 3)
  )
})

test_that("segments not drawn and arrow heads keep the attributes in place", {
  ids_of <- function(p) {
    expect_no_warning(doc <- dsvg_plot(p))
    xml_attr(xml_find_all(doc, ".//*[@data-id]"), "data-id")
  }
  d <- data.frame(
    x = 1:4, y = 1:4, id = c("a", "b", "c", "d"),
    lt = c("blank", "blank", "solid", "solid")
  )
  base <- ggplot(d, aes(x, y, xend = x + 1, yend = y + 1, data_id = id, linetype = lt)) +
    scale_linetype_identity()
  # a blank segment draws neither its line nor its arrow head
  expect_equal(ids_of(base + geom_segment_interactive(arrow = arrow())), c("c", "c", "d", "d"))
  expect_equal(ids_of(base + geom_segment_interactive()), c("c", "d"))
  # two heads with arrows at both ends
  expect_equal(
    ids_of(base + geom_segment_interactive(arrow = arrow(ends = "both"))),
    rep(c("c", "d"), each = 3)
  )
})
