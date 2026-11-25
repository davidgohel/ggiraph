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

# lines giving several elements or none ----
polyline_ids <- function(...) {
  doc <- dsvg_doc(grid.draw(interactive_polyline_grob(...)))
  xml_attr(xml_find_all(doc, ".//polyline"), "data-id")
}

test_that("a line cut by NA gives its value to each of its pieces", {
  expect_equal(
    polyline_ids(
      x = c(0.1, 0.2, NA, 0.3, 0.4, 0.5, 0.6), y = c(0.1, 0.2, NA, 0.3, 0.4, 0.5, 0.6),
      id = c(1, 1, 1, 1, 1, 2, 2), data_id = c("a", "a", "a", "a", "a", "b", "b")
    ),
    c("a", "a", "b")
  )
})

test_that("a piece of a single point is not drawn and takes no value", {
  expect_equal(
    polyline_ids(
      x = c(0.1, NA, 0.3, 0.4, 0.5, 0.6), y = c(0.1, NA, 0.3, 0.4, 0.5, 0.6),
      id = c(1, 1, 1, 1, 2, 2), data_id = rep(c("a", "b"), c(4, 2))
    ),
    c("a", "b")
  )
})

test_that("a line with a blank linetype takes no value", {
  expect_equal(
    polyline_ids(
      x = c(0.1, 0.2, NA, 0.3, 0.4, 0.5, 0.6, NA, 0.7, 0.8),
      y = c(0.1, 0.2, NA, 0.3, 0.4, 0.5, 0.6, NA, 0.7, 0.8),
      id = rep(1:2, each = 5), data_id = rep(c("a", "b"), each = 5),
      gp = gpar(lty = c("blank", "solid"))
    ),
    c("b", "b")
  )
})

test_that("arrow heads take the value of their line", {
  ids <- polyline_ids(
    x = c(0.1, 0.2, 0.3, 0.4, NA, 0.5, 0.6), y = c(0.1, 0.3, 0.2, 0.4, NA, 0.5, 0.6),
    id = c(1, 1, 1, 1, 2, 2, 2), data_id = rep(c("a", "b"), c(4, 3)),
    arrow = arrow(ends = "both")
  )
  doc <- dsvg_doc(grid.draw(interactive_polyline_grob(
    x = c(0.1, 0.2, 0.3, 0.4, NA, 0.5, 0.6), y = c(0.1, 0.3, 0.2, 0.4, NA, 0.5, 0.6),
    id = c(1, 1, 1, 1, 2, 2, 2), data_id = rep(c("a", "b"), c(4, 3)),
    arrow = arrow(ends = "both")
  )))
  # line a: 1 line + 2 heads; line b starts with NA: 1 line + 1 head at the end
  expect_equal(
    xml_attr(xml_find_all(doc, ".//*[@data-id]"), "data-id"),
    c("a", "a", "a", "b", "b")
  )
})
