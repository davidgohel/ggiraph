context("DOM tests")
library(xml2)

test_that("svg is produced when rendered in html", {
  skip_if_not_installed("shinytest")
  library(shinytest)

  app <- ShinyDriver$new(path = system.file(package = "ggiraph", "examples/shiny/crimes"))
  app$waitFor("plot")
  dom <- app$getSource()
  app$stop()

  doc <- read_html(dom)
  expect_equal(xml_length(xml_find_first(doc, "//svg")), 1)
  svg_dom <- xml_find_first(doc, "//svg")
  expect_length(xml_find_all(svg_dom, ".//g/circle"), 50)
  expect_length(xml_find_all(svg_dom, ".//g/circle[@title]"), 50)
  expect_length(xml_find_all(svg_dom, ".//g/circle[@data-id]"), 50)
} )
