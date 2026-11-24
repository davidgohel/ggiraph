# interactive_polyline_grob ----
test_that("interactive_polyline_grob", {
  eval(test_grob, envir = list(name = "interactive_polyline_grob"))
})

test_that("interactive_polyline_grob writes its attributes in the SVG", {
  doc <- dsvg_doc({
    s <- seq(from = 0, to = 4)
    gr <- interactive_polyline_grob(
      x = s,
      y = s,
      tooltip = "tooltip",
      info = "bar",
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//polyline[@info]")
  expect_equal(length(nodes), 1)
  tooltips <- xml_find_all(doc, ".//polyline[@info][@title]")
  expect_equal(length(tooltips), 1)
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, "tooltip")
})

# interactive_lines_grob ----
test_that("interactive_lines_grob", {
  eval(test_grob, envir = list(name = "interactive_lines_grob"))
})

test_that("interactive_lines_grob writes its attributes in the SVG", {
  doc <- dsvg_doc({
    s <- seq(from = 0, to = 4)
    gr <- interactive_lines_grob(
      x = s,
      y = s,
      tooltip = "tooltip",
      info = "bar",
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//polyline[@info]")
  expect_equal(length(nodes), 1)
  tooltips <- xml_find_all(doc, ".//polyline[@info][@title]")
  expect_equal(length(tooltips), 1)
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, "tooltip")
})

test_that("a single value is set on every polyline", {
  doc <- dsvg_doc({
    grid.draw(interactive_polyline_grob(
      x = c(.1, .2, .3, .4, .5, .6, .7, .8, .9),
      y = rep(c(.2, .5, .8), each = 3),
      id = rep(1:3, each = 3),
      tooltip = c("a", "a", "a", "b", "b", "b", "c", "c", "c"),
      info = "bar",
      extra_interactive_params = "info"
    ))
  })
  nodes <- xml_find_all(doc, ".//polyline")
  expect_equal(xml_attr(nodes, "info"), rep("bar", 3))
  expect_equal(xml_attr(nodes, "title"), c("a", "b", "c"))
})
