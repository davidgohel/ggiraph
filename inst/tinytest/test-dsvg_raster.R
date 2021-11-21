library(tinytest)
library(ggiraph)
library(xml2)
source("setup.R")

image <- matrix(hcl(seq(0, 360, length.out = 50 * 50), 80, 70), nrow = 50)

# raster is set correctly ----
{
  doc <- dsvg_doc(standalone = TRUE, srip_ns = FALSE, {
    plot.new()
    rasterImage(image, 0, 0, 10, 10)
  })
  ns <- xml2::xml_ns(doc)
  img_node <- xml_find_first(doc, ".//d1:image")
  expect_inherits(img_node, "xml_node")
  expect_true(xml_has_attr(img_node, "width"))
  expect_true(xml_has_attr(img_node, "height"))
  expect_true(xml_has_attr(img_node, "x"))
  expect_true(xml_has_attr(img_node, "y"))
  expect_equal(xml_attr(img_node, "preserveAspectRatio"), "none")
  expect_false(xml_has_attr(img_node, "image-rendering"))
  expect_true(grepl(x = xml_attr(img_node, "xlink:href", ns = ns), "^data:image/png;base64,.+"))
}

# raster is set correctly with no interpolation ----
{
  doc <- dsvg_doc(standalone = TRUE, srip_ns = FALSE, {
    plot.new()
    rasterImage(image, 0, 0, 10, 10, interpolate = FALSE)
  })
  ns <- xml2::xml_ns(doc)
  img_node <- xml_find_first(doc, ".//d1:image")
  expect_inherits(img_node, "xml_node")
  expect_true(xml_has_attr(img_node, "width"))
  expect_true(xml_has_attr(img_node, "height"))
  expect_true(xml_has_attr(img_node, "x"))
  expect_true(xml_has_attr(img_node, "y"))
  expect_equal(xml_attr(img_node, "preserveAspectRatio"), "none")
  expect_equal(xml_attr(img_node, "image-rendering"), "pixelated")
  expect_true(grepl(x = xml_attr(img_node, "xlink:href", ns = ns), "^data:image/png;base64,.+"))
}

# raster is set correctly with rotation ----
{
  doc <- dsvg_doc(standalone = TRUE, srip_ns = FALSE, {
    plot.new()
    rasterImage(image, 0, 0, 10, 10, angle = 90)
  })
  ns <- xml2::xml_ns(doc)
  img_node <- xml_find_first(doc, ".//d1:image")
  expect_inherits(img_node, "xml_node")
  expect_true(grepl(x = xml_attr(img_node, "transform"), "^rotate(.+)"))
}
