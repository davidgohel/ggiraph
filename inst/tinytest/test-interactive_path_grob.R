library(tinytest)
library(ggiraph)
library(grid)
library(xml2)
source("setup.R")

# interactive_path_grob ----
{
  eval(test_grob, envir = list(name = "interactive_path_grob"))
}

{
  doc <- dsvg_doc({
    s <- seq(from = 0, to = 4)
    gr <- interactive_path_grob(
      x = s,
      y = s,
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

# Using pathId -----
{
  holed_rect <- cbind(
    c(.15, .15, -.15, -.15, .1, .1, -.1, -.1),
    c(.15, -.15, -.15, .15, .1, -.1, -.1, .1)
  )
  holed_rects <- rbind(
    holed_rect + matrix(c(.7, .2), nrow = 8, ncol = 2, byrow = TRUE),
    holed_rect + matrix(c(.7, .8), nrow = 8, ncol = 2, byrow = TRUE),
    holed_rect + matrix(c(.2, .5), nrow = 8, ncol = 2, byrow = TRUE)
  )
  doc <- dsvg_doc({
    gr <- interactive_path_grob(
      x = holed_rects[, 1],
      y = holed_rects[, 2],
      id = rep(1:6, each = 4),
      pathId = rep(1:3, each = 8),
      info = "bar",
      tooltip = paste("tooltip", sort(rep(seq_len(3), 8))),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//path[@info]")
  expect_equal(length(nodes), 3)
  tooltips <- xml_find_all(doc, ".//path[@info][@title]")
  expect_equal(length(tooltips), 3)
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, paste("tooltip", seq_len(3)))
}
