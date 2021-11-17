library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# guide_bins_interactive ----
{
  eval(test_guide, envir = list(name = "guide_bins_interactive"))
}
{
  scale <- scale_size_binned_interactive(
    guide = guide_bins(), tooltip = "tooltip"
  )
  result <- guide_train(guide = scale$guide, scale = scale, aesthetic = "size")
  expect_null(result)
}
{
  doc <- dsvg_plot(
    ggplot(mtcars) +
      geom_point_interactive(
        aes(disp, mpg, size = hp, tooltip = paste(disp, mpg), data_id = paste0(disp, mpg), info = I("test")),
        extra_interactive_params = "info"
      ) +
      scale_size_binned_interactive(
        data_id = function(breaks) {
          as.character(breaks)
        },
        tooltip = function(breaks) {
          as.character(breaks)
        },
        info = "scale",
        extra_interactive_params = "info",
        guide = "bins",
        name = label_interactive("hp",
          data_id = "hp",
          tooltip = "hp", info = "title",
          extra_interactive_params = "info"
        ),
        labels = function(breaks) {
          label_interactive(
            as.character(breaks),
            data_id = as.character(breaks),
            tooltip = as.character(breaks),
            info = rep("label", length(breaks)),
            extra_interactive_params = "info"
          )
        }
      )
  )
  nodes <- xml_find_all(doc, ".//circle[@info='scale']")
  expect_equal(length(nodes), 5, info = "legend keys")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, c("100", "150", "200", "250", "300"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 5, info = "legend labels")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, c("100", "150", "200", "250", "300"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "hp", info = "legend title tooltip")
}
