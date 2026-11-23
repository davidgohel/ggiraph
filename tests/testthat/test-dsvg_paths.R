skip_if(ggiraph:::get_ge_version() < 15, "GE >= 15 is required")

two_circles <- function() {
  gTree(children = gList(
    circleGrob(x = .4, r = .2),
    circleGrob(x = .6, r = .2)
  ))
}

# grid.stroke() draws one path, stroked only -----------------------------
test_that("grid.stroke() draws one path, stroked only", {
  doc <- dsvg_doc(grid.stroke(two_circles(), gp = gpar(col = "navy", lwd = 2)))
  paths <- xml_find_all(doc, "/svg/g//path")
  expect_equal(length(paths), 1L, info = "a single path")
  expect_equal(length(xml_find_all(doc, "/svg/g//circle")), 0L,
               info = "the circles are not drawn")
  d <- xml_attr(paths[[1]], "d")
  expect_equal(lengths(regmatches(d, gregexpr("M ", d))), 2L,
               info = "one subpath per circle")
  expect_equal(xml_attr(paths[[1]], "fill"), "none")
  expect_equal(xml_attr(paths[[1]], "stroke"), "#000080")
})

# grid.fill() uses the fill rule ----------------------------------------
test_that("grid.fill() uses the fill rule", {
  doc <- dsvg_doc(grid.fill(two_circles(), rule = "evenodd",
                            gp = gpar(fill = "orange")))
  path <- xml_find_first(doc, "/svg/g//path")
  expect_equal(xml_attr(path, "fill-rule"), "evenodd")
  expect_equal(xml_attr(path, "fill"), "#FFA500")
  expect_equal(xml_attr(path, "stroke"), "none")

  doc <- dsvg_doc(grid.fill(two_circles(), rule = "winding",
                            gp = gpar(fill = "orange")))
  path <- xml_find_first(doc, "/svg/g//path")
  expect_equal(xml_attr(path, "fill-rule"), "nonzero")
})

# grid.fillStroke() with every kind of shape -----------------------------
test_that("grid.fillStroke() with every kind of shape", {
  doc <- dsvg_doc(grid.fillStroke(
    gTree(children = gList(
      rectGrob(.5, .5, .5, .5),
      polygonGrob(c(.4, .6, .5), c(.4, .4, .6)),
      linesGrob(c(.1, .2), c(.1, .2)),
      segmentsGrob(.8, .8, .9, .9),
      pathGrob(c(.1, .2, .2), c(.8, .8, .9))
    )),
    gp = gpar(fill = linearGradient(), col = "black")
  ))
  paths <- xml_find_all(doc, "/svg/g//path")
  expect_equal(length(paths), 1L, info = "a single path")
  d <- xml_attr(paths[[1]], "d")
  expect_equal(lengths(regmatches(d, gregexpr("M ", d))), 5L,
               info = "one subpath per shape")
  gradient_id <- xml_attr(xml_find_first(doc, "/svg/defs/linearGradient"), "id")
  expect_equal(xml_attr(paths[[1]], "fill"),
               paste0("url(#", gradient_id, ")"), info = "gradient fill")
  expect_equal(xml_attr(paths[[1]], "stroke"), "#000000")
})

# text is not part of a path ---------------------------------------------
test_that("text is not part of a path", {
  expect_warning(
    doc <- dsvg_doc(grid.stroke(gTree(children = gList(
      rectGrob(), textGrob("text")
    )))),
    regexp = "Text is not included"
  )
  expect_equal(length(xml_find_all(doc, "//text")), 0L)
  expect_equal(length(xml_find_all(doc, "/svg/g//path")), 1L)
})

# the path is an interactive element -------------------------------------
test_that("the path is an interactive element", {
  doc <- dsvg_doc({
    grid.newpage()
    ggiraph:::dsvg_tracer_on()
    grid.fill(two_circles(), gp = gpar(fill = "orange"))
    ids <- ggiraph:::dsvg_tracer_off()
  })
  expect_equal(length(ids), 1L, info = "one traced element for the path")

  doc <- dsvg_doc({
    grid.newpage()
    ggiraph:::dsvg_tracer_on()
    grid.fill(two_circles(), gp = gpar(fill = "orange"))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "data-id", ids = ids, values = "a")
  })
  path <- xml_find_first(doc, "/svg/g//path")
  expect_equal(xml_attr(path, "data-id"), "a")
})

# drawing goes on normally after a path -----------------------------------
test_that("drawing goes on normally after a path", {
  doc <- dsvg_doc({
    grid.fill(two_circles(), gp = gpar(fill = "orange"))
    grid.circle(r = .1)
  })
  expect_equal(length(xml_find_all(doc, "/svg/g//circle")), 1L)
})
