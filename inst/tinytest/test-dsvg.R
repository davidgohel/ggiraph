library(tinytest)
library(ggiraph)
library(xml2)
source("setup.R")

# svg creation ------------------------------------------------------------
{
  doc <- dsvg_doc(width = 6, height = 5, {
    plot.new()
  })
  expect_inherits(doc, "xml_document")
  root_node <- xml_root(doc)
  expect_inherits(root_node, "xml_node")
  expect_equal(xml_name(root_node), "svg")

  expect_equal(
    xml_attr(root_node, "viewBox"),
    paste(0, 0, 6 * 72, 5 * 72),
    info = "svg viewBox is set"
  )

  expect_equal(length(xml_children(root_node)), 2)
  defs_node <- xml_find_first(doc, "/svg/defs")
  expect_inherits(defs_node, "xml_node")
  g_node <- xml_find_first(doc, "/svg/g")
  expect_inherits(g_node, "xml_node")
}

# svg dimensions ----------------------------------------------------------
{
  doc <- dsvg_doc(width = 6, height = 5, setdims = TRUE, {
    plot.new()
  })
  root_node <- xml_root(doc)
  expect_equal(as.numeric(xml_attr(root_node, "width")), 6 * 72)
  expect_equal(as.numeric(xml_attr(root_node, "height")), 5 * 72)

  doc <- dsvg_doc(width = 6, height = 5, setdims = FALSE, {
    plot.new()
  })
  root_node <- xml_root(doc)
  expect_false(xml_has_attr(root_node, "width"))
  expect_false(xml_has_attr(root_node, "height"))
}

# svg standalone ----------------------------------------------------------
{
  doc <- dsvg_doc(standalone = TRUE, srip_ns = FALSE, {
    plot.new()
  })
  root_node <- xml_root(doc)
  expect_equal(xml_attr(root_node, "xmlns"), "http://www.w3.org/2000/svg")
  expect_equal(xml_attr(root_node, "xmlns:xlink"), "http://www.w3.org/1999/xlink")

  doc <- dsvg_doc(standalone = FALSE, {
    plot.new()
  })
  root_node <- xml_root(doc)
  expect_false(xml_has_attr(root_node, "xmlns"))
  expect_false(xml_has_attr(root_node, "xmlns:xlink"))
}

# svg background ----------------------------------------------------------
{
  doc <- dsvg_doc(bg = "#123456", {
    plot.new()
  })
  bg_node <- xml_find_first(doc, "/svg/g//rect")
  expect_inherits(bg_node, "xml_node")
  expect_equal(xml_attr(bg_node, "fill"), "#123456")
  expect_false(xml_has_attr(bg_node, "fill-opacity"))

  doc <- dsvg_doc(bg = "#12345699", {
    plot.new()
  })
  bg_node <- xml_find_first(doc, "/svg/g//rect")
  expect_equal(xml_attr(bg_node, "fill-opacity"), "0.6")

  doc <- dsvg_doc(bg = "transparent", {
    plot.new()
  })
  bg_node <- xml_find_first(doc, "/svg/g//rect")
  expect_inherits(bg_node, "xml_missing")
}

# dsvg accepts only one page ----------------------------------------------
{
  expect_error(
    dsvg_doc({
      plot.new()
      plot.new()
    }),
    info = "dsvg accepts only one page"
  )
}
