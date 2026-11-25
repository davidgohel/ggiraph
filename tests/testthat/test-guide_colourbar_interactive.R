colourbar_plot <- function(display, ...) {
  dat <- data.frame(x = 1:10, y = 1:10, z = c(1:5, seq(15, 45, by = 10), 100))
  ggplot(dat, aes(x, y, colour = z)) +
    geom_point() +
    scale_colour_viridis_c_interactive(
      ...,
      guide = guide_colourbar_interactive(display = display)
    )
}

colourbar_keys <- function(p) {
  doc <- dsvg_plot(p)
  xml_find_all(doc, "//*[@key-id]")
}

# colourbar drawn as a single grob ----
test_that("raster and gradient colourbars carry the interactive attributes", {
  for (display in c("raster", "gradient")) {
    nodes <- colourbar_keys(
      colourbar_plot(display, data_id = "bar", tooltip = "my bar")
    )
    expect_length(nodes, 1)
    expect_equal(xml_attr(nodes, "key-id"), "bar", info = display)
    expect_equal(xml_attr(nodes, "title"), "my bar", info = display)
  }
  expect_equal(
    xml_name(colourbar_keys(colourbar_plot("raster", data_id = "bar"))),
    "image"
  )
})

test_that("raster and gradient colourbars give the breaks to a function", {
  for (display in c("raster", "gradient")) {
    expect_no_warning(
      nodes <- colourbar_keys(
        colourbar_plot(display, data_id = function(x) paste(x, collapse = "-"))
      )
    )
    expect_equal(xml_attr(nodes, "key-id"), "0-25-50-75-100", info = display)
  }
})

test_that("raster and gradient colourbars warn when a function returns several values", {
  for (display in c("raster", "gradient")) {
    p <- colourbar_plot(display, data_id = function(x) paste("value", x))
    expect_warning(nodes <- colourbar_keys(p), "single element")
    expect_length(nodes, 0)
  }
})

test_that("raster and gradient colourbars warn when given several values", {
  for (display in c("raster", "gradient")) {
    p <- colourbar_plot(display, data_id = c("a", "b", "c"))
    expect_warning(
      nodes <- colourbar_keys(p),
      "single element"
    )
    expect_length(nodes, 0)
  }
})

# colourbar drawn as rectangles ----
test_that("rectangles colourbar has one value per rectangle", {
  nodes <- colourbar_keys(
    colourbar_plot("rectangles", data_id = function(x) paste0("id", seq_along(x)))
  )
  expect_true(all(xml_name(nodes) == "rect"))
  expect_gt(length(nodes), 1)
  expect_equal(xml_attr(nodes, "key-id"), paste0("id", seq_along(nodes)))
})
