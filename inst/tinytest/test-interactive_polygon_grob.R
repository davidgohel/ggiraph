library(tinytest)
library(ggiraph)
library(grid)
library(xml2)
source("setup.R")

# interactive_polygon_grob ----
{
  eval(test_grob, envir = list(name = "interactive_polygon_grob"))
}

{
  doc <- dsvg_doc({
    gr <- interactive_polygon_grob(
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
}

# Using id.lengths -----
{
  doc <- dsvg_doc({
    gr <- interactive_polygon_grob(
      x = outer(c(0, .5, 1, .5), 5:1 / 5),
      y = outer(c(.5, 1, .5, 0), 5:1 / 5),
      id.lengths = rep(4, 5),
      gp = gpar(fill = 1:5),
      tooltip = paste("tooltip", sort(rep(seq_len(5), 4))),
      info = "bar",
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//polygon[@info]")
  expect_equal(length(nodes), 5)
  tooltips <- xml_find_all(doc, ".//polygon[@info][@title]")
  expect_equal(length(tooltips), 5)
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, paste("tooltip", seq_len(5)))
}
