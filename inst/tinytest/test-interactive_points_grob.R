library(tinytest)
library(ggiraph)
library(grid)
library(xml2)
source("setup.R")

# interactive_points_grob ----
{
  eval(test_grob, envir = list(name = "interactive_points_grob"))
}
{
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.7, length.out = 10)
    gr <- interactive_points_grob(
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

# test all shapes ----
{
  doc <- dsvg_doc({
    sxy <- seq(from = 0.2, to = 0.95, by = 0.15)
    s <- seq.int(from = 0, to = 25)
    gr <- interactive_points_grob(
      x = head(rep(sxy, 5), length(s)),
      y = head(rep(sxy, each = 6), length(s)),
      default.units = "npc",
      pch = s,
      gp = gpar(col = rep("black", length(s)), fill = rep("red", length(s))),
      tooltip = as.character(s),
      info = s,
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  for (i in s) {
    nodes <- xml_find_all(doc, paste0(".//*[@info='", i, "']"))
    expect_true(length(nodes) > 0, info = paste("Shape", i, "is drawn"))
  }
}

{
  gr <- ggiraph:::partialPointGrob(interactive_points_grob(), pch = 2)
  expect_true(ggiraph:::is.zero(gr))
}
