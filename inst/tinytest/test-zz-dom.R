library(tinytest)
library(ggiraph)
library(xml2)

if (!requireNamespace("shinytest", quietly = TRUE)) {
  exit_file("package 'shinytest' is not installed")
}

# svg is produced when rendered in html ----
{
  app <- shinytest::ShinyDriver$new(path = system.file(
    package = "ggiraph",
    "examples/shiny/crimes"
  ))
  app$waitFor("plot")
  dom <- app$getSource()
  app$stop()

  doc <- read_html(dom)
  svg_dom <- xml_find_first(doc, "//svg")
  expect_inherits(svg_dom, "xml_node")
  expect_equal(length(xml_find_all(svg_dom, ".//g/circle")), 50)
  expect_equal(length(xml_find_all(svg_dom, ".//g/circle[@title]")), 50)
  expect_equal(length(xml_find_all(svg_dom, ".//g/circle[@data-id]")), 50)
}
