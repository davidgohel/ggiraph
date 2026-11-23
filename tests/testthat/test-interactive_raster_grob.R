# interactive_raster_grob ----
test_that("interactive_raster_grob", {
  eval(test_grob, envir = list(name = "interactive_raster_grob"))
})
test_that("interactive_raster_grob writes its attributes in the SVG", {
  doc <- dsvg_doc({
    redGradient <- matrix(hcl(0, 80, seq(50, 80, 10)),
      nrow = 4, ncol = 5
    )
    gr <- interactive_raster_grob(
      redGradient,
      tooltip = "tooltip",
      info = "bar",
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//image[@info]")
  expect_equal(length(nodes), 1)
  tooltips <- xml_find_all(doc, ".//image[@info][@title]")
  expect_equal(length(tooltips), 1)
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, "tooltip")
})
