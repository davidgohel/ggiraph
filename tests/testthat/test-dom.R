context("DOM tests")
library(xml2)


test_that("svg is produced when rendered in html", {
  skip_if_not_installed("processx")
  skip_if_not_installed("rdom")
  library(processx)
  library(rdom)

  p <- process$new(R.home('bin/R'),
                   args = c('-e',
                            'shiny::runApp(system.file(package = "ggiraph", "examples/shiny/crimes"), port = 1234)') )
  p$is_alive()

  file <- tempfile(fileext = ".html")
  rdom::rdom("http://127.0.0.1:1234", filename = file)

  p$kill()

  doc <- read_html(file)
  expect_equal(xml_length(xml_find_first(doc, "//svg")), 1)
  svg_dom <- xml_find_first(doc, "//svg")
  expect_match(xml_attr(svg_dom, "preserveaspectratio"), "xMidYMin")
  expect_length(xml_find_all(doc, "//svg/g/circle"), 50)

} )
