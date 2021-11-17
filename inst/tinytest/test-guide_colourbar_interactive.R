library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# guide_colourbar_interactive ----
{
  eval(test_guide, envir = list(name = "guide_colourbar_interactive"))
  eval(test_guide, envir = list(name = "guide_colorbar_interactive"))
}
{
  scale <- scale_colour_continuous_interactive(
    guide = guide_colourbar(), tooltip = "tooltip"
  )
  result <- guide_train(guide = scale$guide, scale = scale, aesthetic = "colour")
  expect_null(result)
}
{
  dat <- expand.grid(x = 0:5, y = 0:5)
  dat$z <- runif(nrow(dat))
  doc <- dsvg_plot(
    ggplot(dat) +
      geom_raster_interactive(
        aes(x, y, fill = z, tooltip = "tooltip", data_id = "raster", info = "test"),
        extra_interactive_params = "info"
      ) +
      scale_fill_gradient_interactive(
        breaks = c(0.25, 0.5, 0.75),
        data_id = "colourbar",
        onclick = "alert(\"colourbar\")",
        tooltip = "colourbar",
        info = "scale",
        extra_interactive_params = "info",
        name = label_interactive(
          "z",
          data_id = "colourbar",
          onclick = "alert(\"colourbar\")",
          tooltip = "colourbar",
          info = "title",
          extra_interactive_params = "info"
        ),
        labels = function(breaks) {
          br <- na.omit(breaks)
          label_interactive(
            as.character(breaks),
            data_id = paste0("colourbar", br),
            tooltip = br,
            info = "label",
            extra_interactive_params = "info"
          )
        }
      )
  )
  nodes <- xml_find_all(doc, ".//image[@info='scale']")
  expect_equal(length(nodes), 1, info = "legend keys")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "colourbar", info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 3, info = "legend labels")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, c("0.25", "0.5", "0.75"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "colourbar", info = "legend title tooltip")
}
