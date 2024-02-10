library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# guide_bins_interactive ----
{
  eval(test_guide, envir = list(name = "guide_bins_interactive"))
}
# continuous scale - bins guide
{
  p <- ggplot(mtcars) +
    geom_point_interactive(
      aes(disp, mpg, size = hp, info = I("test")),
      extra_interactive_params = "info"
    ) +
    scale_size_binned_interactive(
      data_id = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      tooltip = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
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
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//circle[@info='scale']")
  expect_equal(length(nodes), 6, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("50-100", "100-150", "150-200", "200-250", "250-300", "300-350"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 5, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("100", "150", "200", "250", "300"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "hp", info = "legend title tooltip")
}
# continuous scale - bins guide - reverse
{
  p <- ggplot(mtcars) +
    geom_point_interactive(
      aes(disp, mpg, size = hp, info = I("test")),
      extra_interactive_params = "info"
    ) +
    scale_size_binned_interactive(
      data_id = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      tooltip = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      info = "scale",
      extra_interactive_params = "info",
      guide = guide_bins(reverse = TRUE),
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
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//circle[@info='scale']")
  expect_equal(length(nodes), 6, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, rev(c("50-100", "100-150", "150-200", "200-250", "250-300", "300-350")), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 5, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, rev(c("100", "150", "200", "250", "300")), info = "legend labels tooltips")
}
# continuous scale - bins guide - show.limits
{
  p <- ggplot(mtcars) +
    geom_point_interactive(
      aes(disp, mpg, size = hp, info = I("test")),
      extra_interactive_params = "info"
    ) +
    scale_size_binned_interactive(
      data_id = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      tooltip = function(breaks) {
        sapply(seq_along(breaks), function(i) {
          if (i < length(breaks)) {
            paste(
              min(breaks[i], breaks[i + 1], na.rm = TRUE),
              max(breaks[i], breaks[i + 1], na.rm = TRUE),
              sep = "-"
            )
          } else {
            NA_character_
          }
        })
      },
      info = "scale",
      extra_interactive_params = "info",
      guide = guide_bins(show.limits = TRUE),
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
  doc <- dsvg_plot(p)

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 7, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("50", "100", "150", "200", "250", "300", "350"), info = "legend labels tooltips")
}
