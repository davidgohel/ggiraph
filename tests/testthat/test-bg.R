context("Background color")
library(xml2)

test_that("svg background exists if background is not transparent", {

  file <- tempfile()
  dsvg( file = file, bg = "#123456", standalone = FALSE )
  plot.new()
  points(.5, .5 )
  dev.off()

  doc <- read_xml(file)
  bg_node <- xml_find_first(doc, ".//rect[@id]")
  expect_is(object = bg_node, class = "xml_node")
  expect_equal(object = xml_attr(bg_node, "fill"), expected = "#123456")
  expect_equal(object = xml_attr(bg_node, "fill-opacity"), expected = "1")

  file <- tempfile()
  dsvg( file = file, bg = "#12345699", standalone = FALSE )
  plot.new()
  dev.off()

  doc <- read_xml(file)
  bg_node <- xml_find_first(doc, ".//rect[@id]")
  expect_equal(object = xml_attr(bg_node, "fill-opacity"), expected = "0.6")
})


test_that("svg background does not exist if background is transparent", {

  file <- tempfile()
  dsvg( file = file, bg = "transparent", standalone = FALSE )
  plot.new()
  dev.off()

  doc <- read_xml(file)
  bg_node <- xml_find_first(doc, ".//rect[@id]")
  expect_is(bg_node, class = "xml_missing")
})


