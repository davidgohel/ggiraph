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
# guide_train.interactive_coloursteps ----
{
  scale <- scale_colour_continuous_interactive(
    guide = guide_coloursteps(), tooltip = "tooltip"
  )
  result <- guide_train(guide = scale$guide, scale = scale, aesthetic = "colour")
  expect_null(result)
}
{
  dat <- expand.grid(X1 = 1:10, X2 = 1:10)
  dat$value <- dat$X1 * dat$X2
  doc <- dsvg_plot(
    ggplot(dat) +
      geom_tile_interactive(
        aes(X1, X2, fill = value, tooltip = paste(X1, X2), data_id = paste0(X1, X2), info = "test"),
        extra_interactive_params = "info"
      ) +
      scale_fill_binned_interactive(
        breaks = c(25, 50, 75),
        tooltip = "coloursteps",
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
          br <- na.omit(breaks)
          label_interactive(
            as.character(breaks),
            data_id = paste0("coloursteps", br),
            tooltip = br,
            info = "label",
            extra_interactive_params = "info"
          )
        }
      )
  )
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 4, info = "legend keys")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "coloursteps", info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 3, info = "legend labels")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, c("25", "50", "75"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "value", info = "legend title tooltip")
}
