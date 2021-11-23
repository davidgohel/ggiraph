library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)

# girafe ----
{
  g <- girafe(code = print(ggplot()))
  expect_inherits(g, c("girafe", "htmlwidget"))
  doc <- try(
    {
      suppressWarnings(xml2::read_xml(g$x$html))
    },
    silent = TRUE
  )
  expect_inherits(doc, "xml_document")

  g <- girafe(ggobj = ggplot())
  expect_inherits(g, c("girafe", "htmlwidget"))
  doc <- try(
    {
      suppressWarnings(xml2::read_xml(g$x$html))
    },
    silent = TRUE
  )
  expect_inherits(doc, "xml_document")

  expect_error(girafe(ggobj = NULL))

  g <- girafe(ggobj = ggplot(), width_svg = 10, height_svg = 11)
  doc <- try(
    {
      suppressWarnings(xml2::read_xml(g$x$html))
    },
    silent = TRUE
  )
  expect_inherits(doc, "xml_document")
  if (inherits(doc, "xml_document")) {
    root_node <- xml_root(doc)
    expect_inherits(root_node, "xml_node")
    expect_equal(xml_name(root_node), "svg")

    expect_equal(
      xml_attr(root_node, "viewBox"),
      paste(0, 0, 10 * 72, 11 * 72),
      info = "svg viewBox is set"
    )
  }

  g <- girafe(ggobj = ggplot(), options = list(opts_zoom(1, 4), htmlwidgets::sizingPolicy(padding = 0)))
  expect_identical(g$x$settings$zoom, opts_zoom(1, 4))
  expect_identical(g$sizingPolicy, htmlwidgets::sizingPolicy(padding = 0))
}

# girafeOutput ----
{
  result <- girafeOutput("foo")
  expect_inherits(result, "shiny.tag.list")
}

# renderGirafe ----
{
  result <- renderGirafe(girafe(ggobj = ggplot()))
  expect_inherits(result, "shiny.render.function")
}

# girafe_app_paths ----
{
  result <- ggiraph:::girafe_app_paths()
  expect_true(is.character(result) && length(result) > 0)
}

# run_girafe_example ----
{
  expect_error(run_girafe_example("inexistent example"))
}
