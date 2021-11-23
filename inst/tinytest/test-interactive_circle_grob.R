library(tinytest)
library(ggiraph)
library(grid)
library(xml2)
source("setup.R")

# interactive_circle_grob ----
{
  eval(test_grob, envir = list(name = "interactive_circle_grob"))
}
{
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.7, length.out = 10)
    gr <- interactive_circle_grob(
      x = s,
      y = s,
      tooltip = as.character(s),
      info = "bar",
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//circle[@info]")
  expect_equal(length(nodes), length(s))
  tooltips <- xml_find_all(doc, ".//circle[@info][@title]")
  expect_equal(length(tooltips), length(s))
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, as.character(s))
}
