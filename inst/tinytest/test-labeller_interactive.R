library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# labeller_interactive ----
{
  expect_inherits(labeller_interactive(), "labeller")
}
{
  doc <- dsvg_plot(
    ggplot(mtcars, aes(x = mpg, y = wt)) +
      geom_point_interactive(aes(tooltip = row.names(mtcars))) +
      theme(
        strip.text.x = element_text_interactive(),
        strip.text.y = element_text_interactive()
      ) +
      facet_wrap(
        vars(gear),
        labeller = labeller_interactive(
          .mapping = aes(tooltip = paste("Gear:", gear), info = "strip"),
          extra_interactive_params = "info"
        )
      )
  )
  nodes <- xml_find_all(doc, ".//text[@info='strip']")
  expect_equal(length(nodes), length(unique(mtcars$gear)), info = "strip texts")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, paste("Gear:", sort(unique(mtcars$gear))), info = "strip texts tooltips")
}
{
  doc <- dsvg_plot(
    ggplot(mtcars, aes(x = mpg, y = wt)) +
      geom_point_interactive(aes(tooltip = row.names(mtcars))) +
      theme(
        strip.text.x = element_text_interactive(),
        strip.text.y = element_text_interactive()
      ) +
      facet_grid(
        vs + am ~ gear,
        labeller = labeller_interactive(
          gear = labeller_interactive(aes(
            tooltip = paste("gear:", gear), data_id = paste0("gear_", gear), info = "strip1"
          ), extra_interactive_params = "info"),
          vs = labeller_interactive(aes(
            tooltip = paste("VS:", vs), data_id = paste0("vs_", vs), info = "strip2"
          ), extra_interactive_params = "info"),
          am = labeller_interactive(aes(
            tooltip = paste("AM:", am), data_id = paste0("am_", am), info = "strip3"
          ), extra_interactive_params = "info")
        )
      )
  )
  nodes <- xml_find_all(doc, ".//text[@info='strip1']")
  expect_equal(length(nodes), length(unique(mtcars$gear)), info = "strip texts")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(unique(paste0("gear: ", mtcars$gear))), info = "strip texts tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='strip2']")
  expect_equal(length(nodes), length(unique(mtcars$vs)) * length(unique(mtcars$am)), info = "strip texts")
  tooltips <- sort(unique(sapply(nodes, function(node) xml_attr(node, "title"))))
  expect_equal(tooltips, sort(unique(paste0("VS: ", mtcars$vs))), info = "strip texts tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='strip3']")
  expect_equal(length(nodes), length(unique(mtcars$vs)) * length(unique(mtcars$am)), info = "strip texts")
  tooltips <- sort(unique(sapply(nodes, function(node) xml_attr(node, "title"))))
  expect_equal(tooltips, sort(unique(paste0("AM: ", mtcars$am))), info = "strip texts tooltips")
}
