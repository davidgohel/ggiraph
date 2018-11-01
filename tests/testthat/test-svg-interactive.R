context("dsvg interactive functions")
library(xml2)

# tracer -------
test_that("tracer is working", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent" )
  plot.new()
  ggiraph:::dsvg_tracer_on()
  points(c(0.5, .6), c(.4, .3))
  ids <- ggiraph:::dsvg_tracer_off()
  dev.off()

  expect_equal(length(ids), 2 )
  expect_equal(ids, 1:2 )

  doc <- read_xml(file)
  circle_id <- sapply( xml_find_all(doc, ".//circle"), xml_attr, "id" )
  expect_equal(circle_id, as.character(1:2) )
})

# set_attr -------
test_that("attributes are written", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, canvas_id = "svgid" )
  plot.new()
  ggiraph:::dsvg_tracer_on()
  points(c(0.5, .6), c(.4, .3))
  ids <- ggiraph:::dsvg_tracer_off()
  ggiraph:::set_attr(ids = ids, str = c("alert(1)", "alert(2)"), attribute = "onclick" )
  dev.off()

  doc <- read_xml(file)
  script_node <- xml_find_first(doc, ".//script")
  script_txt <-  xml_text(script_node)
  tip1 = "document\\.querySelectorAll\\('#svgid'\\)\\[0\\]\\.getElementById\\('[0-9]+'\\)\\.setAttribute\\('onclick','alert\\(1\\)'\\)"
  tip2 = "document\\.querySelectorAll\\('#svgid'\\)\\[0\\]\\.getElementById\\('[0-9]+'\\)\\.setAttribute\\('onclick','alert\\(2\\)'\\)"
  expect_true( grepl( tip1, script_txt ) )
  expect_true( grepl( tip2, script_txt ) )
})

test_that("attributes cannot contain single quotes", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, canvas_id = "svgid" )
  plot.new()
  ggiraph:::dsvg_tracer_on()
  points(c(0.5, .6), c(.4, .3))
  ids <- ggiraph:::dsvg_tracer_off()
  expect_error(
    ggiraph:::set_attr(ids = ids, str = c("alert('1')", "alert('2')"), attribute = "onclick" )
  )
  dev.off()
})

