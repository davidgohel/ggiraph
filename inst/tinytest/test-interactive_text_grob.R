library(tinytest)
library(ggiraph)
library(grid)
library(xml2)
source("setup.R")

# interactive_text_grob ----
{
  eval(test_grob, envir = list(name = "interactive_text_grob"))
}

{
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.7, length.out = 10)
    gr <- interactive_text_grob(
      paste("label", seq_len(10)),
      x = s,
      y = s,
      tooltip = as.character(s),
      info = rep("bar", 10),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), length(s))
  tooltips <- xml_find_all(doc, ".//text[@info][@title]")
  expect_equal(length(tooltips), length(s))
  tooltips <- sapply(tooltips, xml_attr, "title")
  expect_equal(tooltips, as.character(s))
}
# check.overlap = TRUE
{
  doc <- dsvg_doc({
    gr <- interactive_text_grob(
      paste("label", seq_len(6)),
      x = c(0.1, 0.12, 0.2, 0.2, 0.5, 0.55),
      y = c(0.12, 0.11, 0.2, 0.21, 0.55, 0.55),
      check.overlap = TRUE,
      tooltip = as.character(seq_len(6)),
      info = rep("bar", 6),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), 3)
  tooltips <- xml_find_all(doc, ".//text[@info][@title]")
  expect_equal(length(tooltips), 3)
}
# check.overlap = TRUE and rot
{
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.4, length.out = 10)
    gr <- interactive_text_grob(
      paste("label", seq_len(10)),
      x = s,
      y = s,
      rot = 45,
      check.overlap = TRUE,
      tooltip = as.character(s),
      info = rep("bar", 10),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), 2)
  tooltips <- xml_find_all(doc, ".//text[@info][@title]")
  expect_equal(length(tooltips), 2)
}

# check.overlap = TRUE and expression
{
  doc <- dsvg_doc({
    s <- seq(from = 0.3, to = 0.4, length.out = 10)
    gr <- interactive_text_grob(
      str2expression(paste("label", "^(", seq_len(10), ")")),
      x = s,
      y = s,
      check.overlap = TRUE,
      tooltip = as.character(seq_len(10)),
      info = rep("bar", 10),
      extra_interactive_params = "info"
    )
    grid.draw(gr)
  })

  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), 32)
  tooltips <- xml_find_all(doc, ".//text[@info][@title]")
  expect_equal(length(tooltips), 32)
}
