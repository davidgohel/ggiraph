# geom_label_interactive ----
test_that("geom_label_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_label_interactive"))
})
test_that("geom_label_interactive sets tooltips on boxes and texts", {
  df <- mtcars
  doc <- dsvg_plot(
    ggplot(df, aes(wt, mpg)) +
      geom_label_interactive(
        aes(label = rownames(df), tooltip = row.names(df)),
        info = "geom_label_interactive",
        extra_interactive_params = "info"
      )
  )
  nodes <- xml_find_all(doc, ".//polygon[@info]")
  expect_equal(length(nodes), nrow(df), info = "all polygons are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(row.names(df)), info = "polygon tooltips are set")
  nodes <- xml_find_all(doc, ".//text[@info]")
  expect_equal(length(nodes), nrow(df), info = "all labels are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(row.names(df)), info = "text tooltips are set")
})
