# interactive_rect_grob ----
test_that("interactive_rect_grob", {
  eval(test_grob, envir = list(name = "interactive_rect_grob"))
})

test_that("interactive_rect_grob writes its attributes in the SVG", {
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.7, length.out = 10)
    gr <- interactive_rect_grob(
      x = s,
      y = s,
      tooltip = as.character(s),
      info = "bar",
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//rect[@info]")
  expect_equal(length(nodes), length(s))
  tooltips <- xml_find_all(doc, ".//rect[@info][@title]")
  expect_equal(length(tooltips), length(s))
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, as.character(s))
})
