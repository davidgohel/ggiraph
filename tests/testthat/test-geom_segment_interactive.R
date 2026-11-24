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
