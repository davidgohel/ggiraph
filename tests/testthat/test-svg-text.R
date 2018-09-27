context("dsvg text")
library(xml2)
library(gdtools)

test_that("cex affects strwidth", {

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  w1 <- strwidth("X")
  par(cex = 4)
  w4 <- strwidth("X")
  dev.off()
  expect_equal(w4 / w1, 4, tol = 1e-4)
})


test_that("special characters are escaped", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  text(0.5, 0.5, "<&>")
  dev.off()

  x <- read_xml(file)
  expect_equal(xml_text(xml_find_first(x, ".//text")), "<&>")
})

test_that("utf-8 characters are preserved", {
  skip_on_os("windows") # skip because of xml2 buglet

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  text(0.5, 0.5, "\u00b5")
  dev.off()

  x <- read_xml(file)
  expect_equal(xml_text(xml_find_first(x, ".//text")), "\u00b5")
})

test_that("text color is written in fill attr", {

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  text(0.5, 0.5, "a", col = "#113399")
  dev.off()

  x <- read_xml(file)
  expect_equal(xml_attr(xml_find_first(x, ".//text"), "fill"), "#113399")
})

test_that("default point size is 12", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  text(0.5, 0.5, "a")
  dev.off()

  x <- read_xml(file)
  expect_equal(xml_attr(xml_find_first(x, ".//text"), "font-size"), "9.00pt")
})

test_that("cex generates fractional font sizes", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  text(0.5, 0.5, "a", cex = .1)
  dev.off()

  x <- read_xml(file)
  expect_equal(xml_attr(xml_find_first(x, ".//text"), "font-size"), "0.90pt")
})

test_that("font sets weight/style", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  text(0.5, seq(0.9, 0.1, length = 4), "a", font = 1:4)
  dev.off()

  x <- read_xml(file)
  text <- xml_find_all(x, ".//text")
  expect_equal(xml_attr(text, "font-weight"), c(NA, "bold", NA, "bold"))
  expect_equal(xml_attr(text, "font-style"), c(NA, NA, "italic", "italic"))
})

test_that("font sets weight/style", {
  skip_if_not(font_family_exists("Arial"))
  skip_if_not(font_family_exists("Times New Roman"))
  skip_if_not(font_family_exists("Courier New"))

  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent",
        fonts = list(sans="Arial", serif = "Times New Roman",
                            mono = "Courier New"))
  plot.new()
  text(0.5, 0.1, "a", family = "serif")
  text(0.5, 0.5, "a", family = "sans")
  text(0.5, 0.9, "a", family = "mono")
  dev.off()

  x <- read_xml(file)
  text <- xml_find_all(x, ".//text")
  expect_equal(xml_attr(text, "font-family"), c("Times New Roman", "Arial", "Courier New"))
})

test_that("a symbol has width greater than 0", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent")
  plot(c(0,2), c(0,2), type = "n")
  strw <- strwidth(expression(symbol("\042")))
  dev.off()
  expect_gt(strw, 0)
})

