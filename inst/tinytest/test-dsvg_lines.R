library(tinytest)
library(ggiraph)
library(xml2)
source("setup.R")

# segments have stroke and no fill ----
{
  doc <- dsvg_doc({
    plot.new()
    segments(0.5, 0.5, 1, 1)
  })

  seg_node <- xml_find_first(doc, "//line")
  expect_equal(xml_attr(seg_node, "stroke"), "#000000")
}

# lines have stroke and no fill ----
{
  doc <- dsvg_doc({
    plot.new()
    lines(c(0.5, 1, 0.5), c(0.5, 1, 1))
  })

  seg_node <- xml_find_first(doc, "//polyline")
  expect_equal(xml_attr(seg_node, "fill"), "none")
  expect_equal(xml_attr(seg_node, "stroke"), "#000000")
}

# polygons do have fill and stroke ----
{
  doc <- dsvg_doc({
    plot.new()
    polygon(c(0.5, 1, 0.5), c(0.5, 1, 1), col = "red", border = "blue")
  })

  svg_node <- xml_find_first(doc, "//polygon")
  expect_equal(xml_attr(svg_node, "fill"), "#FF0000")
  expect_equal(xml_attr(svg_node, "stroke"), "#0000FF")
}

# polygons without border have fill and no stroke ----
{
  doc <- dsvg_doc({
    plot.new()
    polygon(c(0.5, 1, 0.5), c(0.5, 1, 1), col = "red", border = NA)
  })

  svg_node <- xml_find_first(doc, "//polygon")
  expect_equal(xml_attr(svg_node, "fill"), "#FF0000")
  expect_equal(xml_attr(svg_node, "stroke"), "none")
}

# paths do have fill and stroke ----
{
  doc <- dsvg_doc({
    plot.new()
    polypath(c(.1, .1, .9, .9, NA, .2, .2, .8, .8),
      c(.1, .9, .9, .1, NA, .2, .8, .8, .2),
      col = "red", border = "blue"
    )
  })

  svg_node <- xml_find_first(doc, "//path")
  expect_equal(xml_attr(svg_node, "fill"), "#FF0000")
  expect_equal(xml_attr(svg_node, "stroke"), "#0000FF")
}

# path fill-rule is set correctly ----
{
  doc <- dsvg_doc({
    plot.new()
    polypath(c(.1, .1, .9, .9, NA, .2, .2, .8, .8),
      c(.1, .9, .9, .1, NA, .2, .8, .8, .2),
      rule = "winding"
    )
  })

  svg_node <- xml_find_first(doc, "//path")
  expect_equal(xml_attr(svg_node, "fill-rule"), "nonzero")

  doc <- dsvg_doc({
    plot.new()
    polypath(c(.1, .1, .9, .9, NA, .2, .2, .8, .8),
      c(.1, .9, .9, .1, NA, .2, .8, .8, .2),
      rule = "evenodd"
    )
  })

  svg_node <- xml_find_first(doc, "//path")
  expect_equal(xml_attr(svg_node, "fill-rule"), "evenodd")
}

# blank lines are omitted ----
{
  doc <- dsvg_doc({
    plot.new()
    lines(1:3, lty = "blank")
  })

  expect_equal(length(xml_find_all(doc, "//polyline")), 0)
}

dash_array <- function(...) {
  doc <- dsvg_doc({
    plot.new()
    lines(c(0, 1), c(0.5, .7), ...)
  })

  dash <- xml_attr(xml_find_first(doc, "//polyline"), "stroke-dasharray")
  as.integer(strsplit(dash, ",")[[1]])
}

# lines lty becomes stroke-dasharray ----
{
  expect_equal(dash_array(lty = 1), NA_integer_)
  expect_equal(dash_array(lty = 2), c(4, 4))
  expect_equal(dash_array(lty = 3), c(1, 3))
  expect_equal(dash_array(lty = 4), c(1, 3, 4, 3))
  expect_equal(dash_array(lty = 5), c(7, 3))
  expect_equal(dash_array(lty = 6), c(2, 2, 6, 2))
  expect_equal(dash_array(lty = "1F"), c(1, 15))
  expect_equal(dash_array(lty = "1234"), c(1, 2, 3, 4))
}

# stroke-dasharray scales with lwd ----
{
  expect_equal(dash_array(lty = 2), c(4, 4))
  expect_equal(dash_array(lty = 2, lwd = 2), c(8, 8))
}

# line end shapes ----
{
  doc <- dsvg_doc({
    plot.new()
    lines(c(0.3, 0.7), c(0.5, 0.5), lwd = 15, lend = "round")
  })
  linecap <- xml_attr(xml_find_first(doc, "//polyline"), "stroke-linecap")
  expect_equal(linecap, "round")

  doc <- dsvg_doc({
    plot.new()
    lines(c(0.3, 0.7), c(0.5, 0.5), lwd = 15, lend = "butt")
  })
  linecap <- xml_attr(xml_find_first(doc, "//polyline"), "stroke-linecap")
  expect_equal(linecap, "butt")

  doc <- dsvg_doc({
    plot.new()
    lines(c(0.3, 0.7), c(0.5, 0.5), lwd = 15, lend = "square")
  })
  linecap <- xml_attr(xml_find_first(doc, "//polyline"), "stroke-linecap")
  expect_equal(linecap, "square")
}

# line join shapes ----
{
  doc <- dsvg_doc({
    plot.new()
    lines(c(0.3, 0.5, 0.7), c(0.1, 0.9, 0.1), lwd = 15, ljoin = "round")
  })
  linejoin <- xml_attr(xml_find_first(doc, "//polyline"), "stroke-linejoin")
  expect_equal(linejoin, "round")

  doc <- dsvg_doc({
    plot.new()
    lines(c(0.3, 0.5, 0.7), c(0.1, 0.9, 0.1), lwd = 15, ljoin = "mitre")
  })
  linejoin <- xml_attr(xml_find_first(doc, "//polyline"), "stroke-linejoin")
  expect_equal(linejoin, "miter")

  doc <- dsvg_doc({
    plot.new()
    lines(c(0.3, 0.5, 0.7), c(0.1, 0.9, 0.1), lwd = 15, ljoin = "bevel")
  })
  linejoin <- xml_attr(xml_find_first(doc, "//polyline"), "stroke-linejoin")
  expect_equal(linejoin, "bevel")
}
