library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# guide_legend_interactive ----
{
  eval(test_guide, envir = list(name = "guide_legend_interactive"))
}
{
  scale <- scale_colour_discrete_interactive(
    guide = guide_legend(), tooltip = "tooltip"
  )
  result <- guide_train(guide = scale$guide, scale = scale, aesthetic = "colour")
  expect_null(result)
}
{
  dat <- data.frame(
    name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
    gender = c("Male", "Female", "Male", "Male", "Male"),
    height = c(169, 160, 171, 172, 171)
  )
  doc <- dsvg_plot(
    ggplot(dat, aes(x = name, y = height, fill = gender)) +
      geom_bar_interactive(
        stat = "identity",
        extra_interactive_params = "info",
        aes(tooltip = name, data_id = name, info = I("test"))
      ) +
      scale_fill_manual_interactive(
        guide = guide_legend(),
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
  )
  nodes <- xml_find_all(doc, ".//rect[@info='scale']")
  expect_equal(length(nodes), 2, info = "legend keys")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, c("Female", "Male"), info = "legend keys tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='label']")
  expect_equal(length(nodes), 2, info = "legend labels")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, c("Female", "Male"), info = "legend labels tooltips")

  nodes <- xml_find_all(doc, ".//text[@info='title']")
  expect_equal(length(nodes), 1, info = "legend title")
  tooltips <- unique(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, "Gender levels", info = "legend title tooltip")
}
