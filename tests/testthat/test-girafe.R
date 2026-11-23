# girafe ----
test_that("girafe", {
  g <- girafe(code = print(ggplot()))
  expect_s3_class(g, c("girafe", "htmlwidget"))
  doc <- try(
    {
      suppressWarnings(xml2::read_xml(g$x$html))
    },
    silent = TRUE
  )
  expect_s3_class(doc, "xml_document")

  g <- girafe(ggobj = ggplot())
  expect_s3_class(g, c("girafe", "htmlwidget"))
  doc <- try(
    {
      suppressWarnings(xml2::read_xml(g$x$html))
    },
    silent = TRUE
  )
  expect_s3_class(doc, "xml_document")

  expect_error(girafe(ggobj = NULL))
  expect_error(girafe(ggobj = "foo"))

  g <- girafe(ggobj = ggplot(), width_svg = 10, height_svg = 11,
              bg = "transparent")
  doc <- try(
    {
      suppressWarnings(xml2::read_xml(g$x$html))
    },
    silent = TRUE
  )
  expect_s3_class(doc, "xml_document")
  if (inherits(doc, "xml_document")) {
    root_node <- xml_root(doc)
    expect_s3_class(root_node, "xml_node")
    expect_equal(xml_name(root_node), "svg")

    expect_equal(
      xml_attr(root_node, "viewBox"),
      paste(0, 0, 10 * 72, 11 * 72),
      info = "svg viewBox is set"
    )
  }

  g <- girafe(ggobj = ggplot(), options = list(opts_zoom(1, 4), htmlwidgets::sizingPolicy(padding = 0)))
  expect_equal(g$x$settings$zoom, opts_zoom(1, 4), ignore_attr = TRUE)
  expect_identical(g$sizingPolicy, htmlwidgets::sizingPolicy(padding = 0))
})

# girafeOutput ----
test_that("girafeOutput", {
  result <- girafeOutput("foo")
  expect_s3_class(result, "shiny.tag.list")
})

# renderGirafe ----
test_that("renderGirafe", {
  skip_if_not_installed("httpuv")
  result <- renderGirafe(girafe(ggobj = ggplot()))
  expect_s3_class(result, "shiny.render.function")
})

# girafe_app_paths ----
test_that("girafe_app_paths", {
  result <- ggiraph:::girafe_app_paths()
  expect_true(is.character(result) && length(result) > 0)
})

# run_girafe_example ----
test_that("run_girafe_example", {
  expect_error(run_girafe_example("inexistent example"))
})
