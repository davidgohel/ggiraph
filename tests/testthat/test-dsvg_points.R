# radius is given in points ----
test_that("radius is given in points", {
  doc <- dsvg_doc(pointsize = 10, {
    plot.new()
    points(0.5, 0.5, cex = 20)
  })

  node <- xml_find_first(doc, ".//circle")
  expect_equal(xml_attr(node, "r"), "33.75pt")
})

# check stroke and fill exist ----
test_that("check stroke and fill exist", {
  doc <- dsvg_doc({
    plot.new()
    points(0.5, 0.5, pch = 21, col = "red", bg = "blue")
  })

  node <- xml_find_first(doc, ".//circle")
  expect_equal(xml_attr(node, "stroke"), "#FF0000")
  expect_equal(xml_attr(node, "fill"), "#0000FF")
})

# check alpha values ----
test_that("check alpha values", {
  doc <- dsvg_doc({
    plot.new()
    points(0.5, 0.5,
      pch = 21, col = rgb(1, 0, 0, 0.5),
      bg = rgb(0, 1, 1, 0.25)
    )
  })

  node <- xml_find_first(doc, ".//circle")
  expect_equal(xml_attr(node, "stroke"), "#FF0000")
  expect_equal(xml_attr(node, "stroke-opacity"), "0.5")
  expect_equal(xml_attr(node, "fill"), "#00FFFF")
  expect_equal(xml_attr(node, "fill-opacity"), "0.25")
})

# check fill is set to none when necessary ----
test_that("check fill is set to none when necessary", {
  doc <- dsvg_doc({
    plot.new()
    points(0.5, 0.5, pch = 21, col = 3, bg = NA)
  })

  node <- xml_find_first(doc, ".//circle")
  expect_equal(xml_attr(node, "fill"), "none")
})
