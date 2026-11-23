skip_if(ggiraph:::get_ge_version() < 13, "GE >= 13 is required")

# Vieport clip is set to a grob
test_that("Vieport clip is set to a grob", {
  doc <- dsvg_doc(width = 6, height = 5, {
    pushViewport(viewport(clip = circleGrob()))
    grid.rect(gp = gpar(col = NA, fill = "red"))
    popViewport()
  })

  clip_paths <- xml_find_all(doc, "/svg/defs/clipPath")
  expect_equal(length(clip_paths), 2, info = "must have two clipPaths defined")
  clip <- clip_paths[[2]]
  id <- xml_attr(clip, "id")
  child <- xml_child(clip)
  expect_equal(xml_name(child), "circle", info = "clipPath child must be the circle")

  rect <- xml_find_first(doc, "/svg/g//rect")
  expect_s3_class(rect, "xml_node")
  g <- xml_parent(rect)
  clipid <- xml_attr(g, "clip-path")
  expect_equal(clipid, paste0("url(#", id, ")"), info = "rect g has correct clip id")
})

# Vieport mask is set to a grob
test_that("Vieport mask is set to a grob", {
  doc <- dsvg_doc(width = 6, height = 5, {
    pushViewport(viewport(mask = circleGrob()))
    grid.rect(gp = gpar(col = NA, fill = "green"))
    popViewport()
  })

  mask <- xml_find_first(doc, "/svg/defs/mask")
  expect_s3_class(mask, "xml_node")
  id <- xml_attr(mask, "id")
  child <- xml_find_first(mask, ".//circle")
  expect_equal(xml_name(child), "circle", info = "mask child must be the circle")

  rect <- xml_find_first(doc, "/svg/g//rect")
  expect_s3_class(rect, "xml_node")
  maskid <- xml_attr(rect, "mask")
  expect_equal(maskid, paste0("url(#", id, ")"), info = "rect g has correct mask id")
})

# Patterns
test_that("Patterns", {
  doc <- dsvg_doc(width = 6, height = 5, {
    grid.rect(gp = gpar(col = NA, fill = linearGradient()))
    grid.rect(gp = gpar(col = NA, fill = radialGradient(colours = c(adjustcolor("red", 0.5), "green"))))
    pat <- pattern(polygonGrob(unit(.5, "npc") + unit(c(-2, 0, 2, 0), "mm"),
                               unit(.5, "npc") + unit(c(0, 2, 0, -2), "mm"),
                               gp=gpar(col=NA, fill="grey")),
                   width=unit(4, "mm"), height=unit(4, "mm"),
                   extend="repeat")
    grid.rect(gp = gpar(col = NA, fill = pat))
  })

  # each rect is filled with its own paint server, defined in <defs>
  fills <- xml_attr(xml_find_all(doc, "//g[@id='svgid_rootg']//rect"), "fill")
  ids <- sub("^url\\(#(.*)\\)$", "\\1", fills)
  kinds <- vapply(ids, function(id) {
    xml_name(xml_find_first(doc, sprintf("//defs/*[@id='%s']", id)))
  }, character(1), USE.NAMES = FALSE)
  expect_equal(kinds, c("linearGradient", "radialGradient", "pattern"))

  # gradient stops keep their colours and alpha
  stops <- xml_find_all(doc, "//radialGradient/stop")
  expect_equal(xml_attr(stops, "stop-color"), c("#FF0000", "#00FF00"))
  expect_equal(xml_attr(stops, "stop-opacity"), c("0.5", "1"))

  # the pattern tile contains the polygon
  expect_length(xml_find_all(doc, "//pattern//polygon"), 1)
})
