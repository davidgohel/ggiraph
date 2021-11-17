library(tinytest)
library(ggiraph)
library(grid)
library(xml2)
source("setup.R")

# interactive_curve_grob ----
{
  eval(test_grob, envir = list(name = "interactive_curve_grob"))
}

{
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.7, length.out = 10)
    s2 <- seq(from = 0.4, to = 0.8, length.out = 10)
    gr <- interactive_curve_grob(
      x1 = s,
      y1 = s,
      x2 = s2,
      y2 = s2,
      tooltip = "tooltip",
      info = "bar",
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//polyline[@info]")
  expect_equal(length(nodes), length(s))
  tooltips <- xml_find_all(doc, ".//polyline[@info][@title]")
  expect_equal(length(tooltips), length(s))
  tooltips <- unique(sapply(tooltips, xml_attr, "title"))
  expect_equal(tooltips, "tooltip")
}
