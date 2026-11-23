# geom_dotplot_interactive ----
test_that("geom_dotplot_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_dotplot_interactive"))
})
test_that("geom_dotplot_interactive draws every dot with its tooltip", {
  df <- mtcars
  doc <- dsvg_plot(
    ggplot(df, aes(x = mpg)) +
      geom_dotplot_interactive(
        aes(tooltip = row.names(df)),
        info = "geom_dotplot_interactive",
        extra_interactive_params = "info",
        binwidth = 1
      )
  )
  nodes <- xml_find_all(doc, ".//circle[@info]")
  expect_equal(length(nodes), nrow(df), info = "all dots are drawn")
  tooltips <- sort(sapply(nodes, function(node) xml_attr(node, "title")))
  expect_equal(tooltips, sort(row.names(df)), info = "tooltips are set")
})
