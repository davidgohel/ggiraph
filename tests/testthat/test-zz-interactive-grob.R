context("dsvg interactive functions")
library(xml2)
library(grid)

# interactive_points_grob -------
test_that("interactive_points_grob is working", {
  file <- tempfile(fileext = ".svg")
  dsvg(
    file = file,
    standalone = FALSE,
    bg = "transparent",
    canvas_id = "svgid"
  )
  s <- seq(1:10)
  gr <- interactive_points_grob(
    x = s,
    y = s,
    tooltip = as.character(s),
    data_id = as.character(s)
  )
  grid.draw(gr)
  dev.off()

  doc <- read_xml(file)
  circles <- xml_find_all(doc, ".//circle")
  expect_length(circles, length(s))
  circle_id <- sapply(circles, xml_attr, "id" )
  expect_equal(circle_id, paste0("svgid_el_", as.character(s)))
  tooltips <- xml_find_all(doc, ".//circle[@title]")
  expect_length(tooltips, length(s))
  circle_tooltips <- sapply(tooltips, xml_attr, "title" )
  expect_equal(circle_tooltips, as.character(s))
  data_ids <- xml_find_all(doc, ".//circle[@data-id]")
  expect_length(data_ids, length(s))
  circle_data_ids <- sapply(tooltips, xml_attr, "data-id" )
  expect_equal(circle_data_ids, as.character(s))
})
