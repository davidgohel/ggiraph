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
# continuous scale - colourbar guide
{
  set.seed(4393)
  dat <- expand.grid(x = 0:5, y = 0:5)
  dat$z <- runif(nrow(dat))
  p <- ggplot(dat) +
    geom_raster_interactive(
      aes(x, y, fill = z, tooltip = "tooltip", data_id = "raster", info = "test"),
      extra_interactive_params = "info"
    ) +
    scale_fill_gradient_interactive(
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
        label_interactive(
          as.character(breaks),
          data_id = paste0("colourbar", breaks),
          tooltip = breaks,
          info = "label",
          extra_interactive_params = "info"
        )
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//image[@info='scale']")
  expect_equal(length(nodes), 1, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, "colourbar", info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 3, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("0.25", "0.5", "0.75"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "colourbar", info = "legend title tooltip")
}
# continuous scale - colourbar guide - reverse
{
  set.seed(4393)
  dat <- expand.grid(x = 0:5, y = 0:5)
  dat$z <- runif(nrow(dat))
  p <- ggplot(dat) +
    geom_raster_interactive(
      aes(x, y, fill = z, tooltip = "tooltip", data_id = "raster", info = "test"),
      extra_interactive_params = "info"
    ) +
    scale_fill_gradient_interactive(
      guide = guide_colourbar(reverse = TRUE),
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
        label_interactive(
          as.character(breaks),
          data_id = paste0("colourbar", breaks),
          tooltip = breaks,
          info = "label",
          extra_interactive_params = "info"
        )
      }
    )
  doc <- dsvg_plot(p)

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 3, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("0.25", "0.5", "0.75"), info = "legend labels tooltips")
}

# continuous scale - colourbar guide - not raster
{
  set.seed(4393)
  dat <- expand.grid(x = 0:5, y = 0:5)
  dat$z <- runif(nrow(dat))
  p <- ggplot(dat) +
    geom_raster_interactive(
      aes(x, y, fill = z, tooltip = "tooltip", data_id = "raster", info = "test"),
      extra_interactive_params = "info"
    ) +
    scale_fill_gradient_interactive(
      guide = guide_colourbar(raster = FALSE, nbin = 5),
      data_id = function(breaks) {
        as.character(round(breaks, 2))
      },
      tooltip = function(breaks) {
        as.character(round(breaks, 2))
      },
      info = "scale",
      extra_interactive_params = "info"
    )
  doc <- dsvg_plot(p)

  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 5, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("0.03", "0.27", "0.51", "0.76", "1"), info = "legend keys tooltips")
}
