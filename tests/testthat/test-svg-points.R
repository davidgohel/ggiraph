context("dsvg points")
library(xml2)

test_that("radius is given in points", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent", pointsize = 10 )
  plot.new()
  points(0.5, 0.5, cex = 20)
  dev.off()

  x <- read_xml(file)
  node <- xml_find_first(x, ".//circle")

  expect_equal(xml_attr(node, "r"), "33.75pt")
})

test_that("check stroke and fill exist", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent", pointsize = 10 )
  plot.new()
  points(0.5, 0.5, pch = 21, col = "red", bg = "blue")
  dev.off()

  x <- read_xml(file)
  node <- xml_find_first(x, ".//circle")
  expect_equal(xml_attr(node, "stroke"), "#FF0000")
  expect_equal(xml_attr(node, "fill"), "#0000FF")
})

test_that("check alpha values", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent", pointsize = 10 )
  plot.new()
  points(0.5, 0.5, pch = 21, col = rgb(1, 0, 0, 0.5),
         bg = rgb(0, 1, 1, 0.25))
  dev.off()

  x <- read_xml(file)
  node <- xml_find_first(x, ".//circle")
  expect_equal(xml_attr(node, "stroke"), "#FF0000" )
  expect_equal(xml_attr(node, "stroke-opacity"), "0.5")
  expect_equal(xml_attr(node, "fill"), "#00FFFF")
  expect_equal(xml_attr(node, "fill-opacity"), "0.25")
})

test_that("check fill is set to none when necessary", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent", pointsize = 10 )
  plot.new()
  points(0.5, 0.5, pch = 21, col = 3, bg = NA)
  dev.off()

  x <- read_xml(file)
  node <- xml_find_first(x, ".//circle")
  expect_match(xml_attr(node, "fill"), "none")
})

