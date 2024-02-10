library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# guide_coloursteps_interactive ----
{
  eval(test_guide, envir = list(name = "guide_coloursteps_interactive"))
  eval(test_guide, envir = list(name = "guide_colorsteps_interactive"))
}
# continuous scale - colourstep guide
{
  set.seed(4393)
  dat <- expand.grid(X1 = 1:10, X2 = 1:10)
  dat$value <- dat$X1 * dat$X2
  p <- ggplot(dat) +
    geom_tile_interactive(
      aes(X1, X2, fill = value, tooltip = paste(X1, X2), data_id = paste0(X1, X2), info = "test"),
      extra_interactive_params = "info"
    ) +
    scale_fill_binned_interactive(
      breaks = c(25, 50, 75),
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
      name = label_interactive(
        "value",
        data_id = "coloursteps.title",
        tooltip = "value",
        info = "title",
        extra_interactive_params = "info"
      ),
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = paste0("coloursteps", breaks),
          tooltip = breaks,
          info = "label",
          extra_interactive_params = "info"
        )
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 4, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("1-25", "25-50", "50-75", "75-100"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 3, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("25", "50", "75"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "value", info = "legend title tooltip")
}
# continuous scale - colourstep guide - reverse
{
  set.seed(4393)
  dat <- expand.grid(X1 = 1:10, X2 = 1:10)
  dat$value <- dat$X1 * dat$X2
  p <- ggplot(dat) +
    geom_tile_interactive(
      aes(X1, X2, fill = value, tooltip = paste(X1, X2), data_id = paste0(X1, X2), info = "test"),
      extra_interactive_params = "info"
    ) +
    scale_fill_binned_interactive(
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
      guide = guide_colorsteps(reverse = TRUE),
      name = label_interactive(
        "value",
        data_id = "coloursteps.title",
        tooltip = "value",
        info = "title",
        extra_interactive_params = "info"
      ),
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = paste0("coloursteps", breaks),
          tooltip = breaks,
          info = "label",
          extra_interactive_params = "info"
        )
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 4, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("75-100", "50-75", "25-50", "0-25"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 3, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("25", "50", "75"), info = "legend labels tooltips")
}
# continuous scale - colourstep guide - uneven steps
{
  set.seed(4393)
  dat <- expand.grid(X1 = 1:10, X2 = 1:10)
  dat$value <- dat$X1 * dat$X2
  p <- ggplot(dat) +
    geom_tile_interactive(
      aes(X1, X2, fill = value, tooltip = paste(X1, X2), data_id = paste0(X1, X2), info = "test"),
      extra_interactive_params = "info"
    ) +
    scale_fill_binned_interactive(
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
      guide = guide_colorsteps(even.steps = FALSE),
      name = label_interactive(
        "value",
        data_id = "coloursteps.title",
        tooltip = "value",
        info = "title",
        extra_interactive_params = "info"
      ),
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = paste0("coloursteps", breaks),
          tooltip = breaks,
          info = "label",
          extra_interactive_params = "info"
        )
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 100, info = "legend keys")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, c("0-25", "25-50", "50-75", "75-100"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 3, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("25", "50", "75"), info = "legend labels tooltips")
}
