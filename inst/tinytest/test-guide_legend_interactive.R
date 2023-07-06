library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# guide_legend_interactive ----
{
  eval(test_guide, envir = list(name = "guide_legend_interactive"))
}
# discrete scale - legend guide
{
  dat <- data.frame(
    name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
    gender = c("Male", "Female", "Male", "Male", "Male"),
    height = c(169, 160, 171, 172, 171)
  )
  p <- ggplot(dat, aes(x = name, y = height, fill = gender)) +
    geom_bar_interactive(
      stat = "identity",
      extra_interactive_params = "info",
      aes(info = I("test"))
    ) +
    scale_fill_manual_interactive(
      guide = "legend",
      name = label_interactive("gender",
        tooltip = "Gender levels", data_id = "legend.title",
        info = "title", extra_interactive_params = "info"
      ),
      extra_interactive_params = "info",
      values = c(Male = "#0072B2", Female = "#009E73"),
      data_id = c(Female = "Female", Male = "Male"),
      tooltip = c(Male = "Male", Female = "Female"),
      info = c(Male = "scale", Female = "scale"),
      labels = function(breaks) {
        lapply(breaks, function(br) {
          label_interactive(
            as.character(br),
            data_id = as.character(br),
            tooltip = as.character(br),
            info = "label",
            extra_interactive_params = "info"
          )
        })
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 2, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("Female", "Male"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 2, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("Female", "Male"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "Gender levels", info = "legend title tooltip")
}
# discrete scale - legend guide - reverse
{
  dat <- data.frame(
    name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
    gender = c("Male", "Female", "Male", "Male", "Male"),
    height = c(169, 160, 171, 172, 171)
  )
  p <- ggplot(dat, aes(x = name, y = height, fill = gender)) +
    geom_bar_interactive(
      stat = "identity",
      extra_interactive_params = "info",
      aes(info = I("test"))
    ) +
    scale_fill_manual_interactive(
      guide = guide_legend(reverse = TRUE),
      name = label_interactive("gender",
        tooltip = "Gender levels", data_id = "legend.title",
        info = "title", extra_interactive_params = "info"
      ),
      extra_interactive_params = "info",
      values = c(Male = "#0072B2", Female = "#009E73"),
      data_id = c(Female = "Female", Male = "Male"),
      tooltip = c(Male = "Male", Female = "Female"),
      info = c(Male = "scale", Female = "scale"),
      labels = function(breaks) {
        lapply(breaks, function(br) {
          label_interactive(
            as.character(br),
            data_id = as.character(br),
            tooltip = as.character(br),
            info = "label",
            extra_interactive_params = "info"
          )
        })
      }
    )
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 2, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("Male", "Female"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 2, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("Male", "Female"), info = "legend labels tooltips")
}
# continuous scale - legend guide
{
  set.seed(4393)
  dsmall <- diamonds[sample(nrow(diamonds), 1000), ]
  p <- ggplot(dsmall, aes(x, y)) +
    geom_density_2d_filled_interactive(
      aes(
        fill = after_stat(nlevel),
        tooltip = paste("nlevel:", after_stat(nlevel))
      ),
      extra_interactive_params = "info"
    ) +
    facet_grid(. ~ cut) +
    scale_fill_viridis_c_interactive(
      data_id = function(breaks) {
        as.character(breaks)
      },
      tooltip = function(breaks) {
        as.character(breaks)
      },
      info = "scale",
      extra_interactive_params = "info",
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = as.character(breaks),
          onclick = paste0("alert(\"", as.character(breaks), "\")"),
          tooltip = as.character(breaks),
          info = rep("label", length(breaks)),
          extra_interactive_params = "info"
        )
      },
      name = label_interactive("nlevel",
        data_id = "nlevel", tooltip = "nlevel",
        info = "title", extra_interactive_params = "info"
      ),
      guide = "legend"
    )
  girafe(ggobj = p)
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 4, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("0.25", "0.5", "0.75", "1"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 4, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, c("0.25", "0.5", "0.75", "1"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "nlevel", info = "legend title tooltip")
}
# continuous scale - legend guide - reverse
{
  set.seed(4393)
  dsmall <- diamonds[sample(nrow(diamonds), 1000), ]
  p <- ggplot(dsmall, aes(x, y)) +
    geom_density_2d_filled_interactive(
      aes(
        fill = after_stat(nlevel),
        tooltip = paste("nlevel:", after_stat(nlevel))
      ),
      extra_interactive_params = "info"
    ) +
    facet_grid(. ~ cut) +
    scale_fill_viridis_c_interactive(
      data_id = function(breaks) {
        as.character(breaks)
      },
      tooltip = function(breaks) {
        as.character(breaks)
      },
      info = "scale",
      extra_interactive_params = "info",
      labels = function(breaks) {
        label_interactive(
          as.character(breaks),
          data_id = as.character(breaks),
          onclick = paste0("alert(\"", as.character(breaks), "\")"),
          tooltip = as.character(breaks),
          info = rep("label", length(breaks)),
          extra_interactive_params = "info"
        )
      },
      name = label_interactive("nlevel",
        data_id = "nlevel", tooltip = "nlevel",
        info = "title", extra_interactive_params = "info"
      ),
      guide = guide_legend(reverse = TRUE)
    )
  girafe(ggobj = p)
  doc <- dsvg_plot(p)
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 4, info = "legend keys")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, rev(c("0.25", "0.5", "0.75", "1")), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 4, info = "legend labels")
  tooltips <- sapply(nodes, function(node) xml_attr(node, "title"))
  expect_equal(tooltips, rev(c("0.25", "0.5", "0.75", "1")), info = "legend labels tooltips")
}
