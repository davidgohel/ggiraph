library(tinytest)
library(ggiraph)
library(grid)
library(xml2)
source("setup.R")

# interactive_polyline_grob ----
{
  eval(test_grob, envir = list(name = "interactive_polyline_grob"))
}

{
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
}

# interactive_lines_grob ----
{
  eval(test_grob, envir = list(name = "interactive_lines_grob"))
}

{
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
}
