library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

if (!requireNamespace("ggrepel", quietly = TRUE)) {
  exit_file("package 'ggrepel' is not installed")
}

# geom_text_repel_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_text_repel_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_label_repel_interactive"))
}
{
  df <- mtcars
  df$carname <- rownames(df)
  doc <- dsvg_plot(
    ggplot(df, aes(wt, mpg)) +
      geom_text_repel_interactive(
        aes(label = carname, tooltip = carname, info = "geom_text_repel_interactive"),
        extra_interactive_params = "info",
        max.overlaps = 100
      )
  )
  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), nrow(df), info = "all texts are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(row.names(df)), "text tooltips are set")
}
{
  df <- mtcars
  df$carname <- rownames(df)
  doc <- dsvg_plot(
    ggplot(df, aes(wt, mpg)) +
      geom_label_repel_interactive(
        aes(label = carname, tooltip = carname, info = "geom_label_repel_interactive"),
        extra_interactive_params = "info",
        max.overlaps = 100
      )
  )
  nodes <- xml_find_all(doc, ".//polygon[@info]")
  expect_equal(length(nodes), nrow(df), info = "all polygons are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(row.names(df)), "polygon tooltips are set")
  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), nrow(df), info = "all texts are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(row.names(df)), "text tooltips are set")
}
