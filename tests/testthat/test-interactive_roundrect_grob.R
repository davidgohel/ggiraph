# interactive_roundrect_grob ----
test_that("interactive_roundrect_grob", {
  eval(test_grob, envir = list(name = "interactive_roundrect_grob"))
})

test_that("interactive_roundrect_grob writes its attributes in the SVG", {
  doc <- dsvg_doc({
    gr <- interactive_roundrect_grob(
      gp = gpar(fill = "black"),
      tooltip = "tooltip",
      info = "bar",
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//polygon[@info]")
  expect_equal(length(nodes), 1)
  tooltips <- xml_find_all(doc, ".//polygon[@info][@title]")
  expect_equal(length(tooltips), 1)
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, "tooltip")
})
