context("dsvg lines")
library(xml2)

test_that("segments have stroke and no fill", {

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  segments(0.5, 0.5, 1, 1)
  dev.off()

  x <- read_xml(file)
  seg_node <- xml_find_first(x, "//line")
  expect_match(xml_attr(seg_node, "fill"), "none")
  expect_match(xml_attr(seg_node, "stroke"), "#000000")
})

test_that("lines have stroke and no fill", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(c(0.5, 1, 0.5), c(0.5, 1, 1))
  dev.off()

  x <- read_xml(file)
  seg_node <- xml_find_first(x, "//polyline")
  expect_match(xml_attr(seg_node, "fill"), "none")
  expect_match(xml_attr(seg_node, "stroke"), "#000000")
})

test_that("polygons do have fill and stroke", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  polygon(c(0.5, 1, 0.5), c(0.5, 1, 1), col = "red", border = "blue")
  dev.off()

  x <- read_xml(file)
  svg_node <- xml_find_first(x, "//polygon")
  expect_match(xml_attr(svg_node, "fill"), "#FF0000")
  expect_match(xml_attr(svg_node, "stroke"), "#0000FF")
})

test_that("polygons without border have fill and no stroke", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  polygon(c(0.5, 1, 0.5), c(0.5, 1, 1), col = "red", border = NA)
  dev.off()

  x <- read_xml(file)
  svg_node <- xml_find_first(x, "//polygon")
  expect_equal(xml_attr(svg_node, "fill"), "#FF0000")
  expect_equal(xml_attr(svg_node, "stroke"), "none")
})


test_that("blank lines are omitted", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(1:3, lty = "blank")
  dev.off()
  doc <- read_xml(file)
  expect_equal(length(xml_find_all(doc, "//polyline")), 0)
})

dash_array <- function(...) {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(c(0,1), c(0.5,.7), ...)
  dev.off()
  doc <- read_xml(file)
  dash <- xml_attr(xml_find_first(doc, "//polyline"), "stroke-dasharray")
  as.integer(strsplit(dash, ",")[[1]])
}

test_that("lines lty becomes stroke-dasharray", {
  expect_equal(dash_array(lty = 1), NA_integer_)
  expect_equal(dash_array(lty = 2), c(4, 4))
  expect_equal(dash_array(lty = 3), c(1, 3))
  expect_equal(dash_array(lty = 4), c(1, 3, 4, 3))
  expect_equal(dash_array(lty = 5), c(7, 3))
  expect_equal(dash_array(lty = 6), c(2, 2, 6, 2))
  expect_equal(dash_array(lty = "1F"), c(1, 15))
  expect_equal(dash_array(lty = "1234"), c(1, 2, 3, 4))
})

test_that("stroke-dasharray scales with lwd", {
  expect_equal(dash_array(lty = 2), c(4, 4))
  expect_equal(dash_array(lty = 2, lwd = 2), c(8, 8))
})

test_that("line end shapes", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(c(0.3, 0.7), c(0.5, 0.5), lwd = 15, lend = "round")
  dev.off()
  x1 <- read_xml(file)

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(c(0.3, 0.7), c(0.5, 0.5), lwd = 15, lend = "butt")
  dev.off()
  x2 <- read_xml(file)

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(c(0.3, 0.7), c(0.5, 0.5), lwd = 15, lend = "square")
  dev.off()
  x3 <- read_xml(file)

  linecap <- xml_attr(xml_find_first(x1, "//polyline"), "stroke-linecap")
  expect_match(linecap, "round")

  linecap <- xml_attr(xml_find_first(x2, "//polyline"), "stroke-linecap")
  expect_match(linecap, "butt")

  linecap <- xml_attr(xml_find_first(x3, "//polyline"), "stroke-linecap")
  expect_match(linecap, "square")
})

test_that("line join shapes", {

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(c(0.3, 0.5, 0.7), c(0.1, 0.9, 0.1), lwd = 15, ljoin = "round")
  dev.off()
  x1 <- read_xml(file)
  linejoin <- xml_attr(xml_find_first(x1, "//polyline"), "stroke-linejoin")
  expect_match(linejoin, "round")

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(c(0.3, 0.5, 0.7), c(0.1, 0.9, 0.1), lwd = 15, ljoin = "mitre")
  dev.off()
  x2 <- read_xml(file)
  linejoin <- xml_attr(xml_find_first(x2, "//polyline"), "stroke-linejoin")
  expect_match(linejoin, "miter")

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  lines(c(0.3, 0.5, 0.7), c(0.1, 0.9, 0.1), lwd = 15, ljoin = "bevel")
  dev.off()
  x3 <- read_xml(file)
  linejoin <- xml_attr(xml_find_first(x3, "//polyline"), "stroke-linejoin")
  expect_match(linejoin, "bevel")
})