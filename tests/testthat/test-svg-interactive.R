context("dsvg interactive functions")
library(xml2)

# tracer -------
test_that("tracer is working", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, bg = "transparent", canvas_id = "svgid" )
  plot.new()
  ggiraph:::dsvg_tracer_on()
  points(c(0.5, .6), c(.4, .3))
  ids <- ggiraph:::dsvg_tracer_off()
  dev.off()

  expect_equal(length(ids), 2 )
  expect_equal(ids, 1:2 )

  doc <- read_xml(file)
  circle_id <- sapply( xml_find_all(doc, ".//circle"), xml_attr, "id" )
  expect_equal(circle_id, paste0("svgid_el_", as.character(1:2)) )
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
  comment_nodes <- xml_find_all(doc, "//*[local-name() = 'comment']")
  expect_equal(length(comment_nodes), 2)
  comment <- comment_nodes[[1]]
  expect_match(xml_attr(comment, "target"), "[0-9]+")
  expect_equal(xml_attr(comment, "attr"), "onclick")
  expect_equal(xml_text(comment), "alert(1)")
  comment <- comment_nodes[[2]]
  expect_match(xml_attr(comment, "target"), "[0-9]+")
  expect_equal(xml_attr(comment, "attr"), "onclick")
  expect_equal(xml_text(comment), "alert(2)")
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

# set_svg_attributes -------
test_that("attributes are written from comments", {
  file <- tempfile(fileext = ".svg")
  dsvg( file = file, standalone = FALSE, canvas_id = "svgid" )
  plot.new()
  ggiraph:::dsvg_tracer_on()
  points(c(0.5, .6), c(.4, .3))
  ids <- ggiraph:::dsvg_tracer_off()
  ggiraph:::set_attr(ids = ids, str = c("alert(1)", "alert(2)"), attribute = "onclick" )
  dev.off()

  doc <- read_xml(file)
  ggiraph:::set_svg_attributes(doc, "svgid")
  comment_nodes <- xml_find_all(doc, "//*[local-name() = 'comment']")
  expect_equal(length(comment_nodes), 0)
  circles <- xml_find_all(doc, ".//circle")
  expect_length(circles, 2)
  circles_with_onclick <- xml_find_all(doc, ".//circle[@onclick]")
  expect_length(circles_with_onclick, 2)
  onclicks <- sapply(circles, xml_attr, "onclick" )
  expect_equal(onclicks, paste0("alert(", as.character(seq(1:2)), ")"))
})
