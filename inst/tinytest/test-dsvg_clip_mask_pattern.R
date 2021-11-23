library(tinytest)
library(ggiraph)
library(grid)
library(xml2)
source("setup.R")

if (ggiraph:::get_ge_version() < 13) {
  exit_file("GE >= 13 is required")
}

# Vieport clip is set to a grob
{
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
  expect_inherits(rect, "xml_node", info = "rect found")
  g <- xml_parent(rect)
  clipid <- xml_attr(g, "clip-path")
  expect_equal(clipid, paste0("url(#", id, ")"), info = "rect g has correct clip id")
}

# Vieport mask is set to a grob
{
  doc <- dsvg_doc(width = 6, height = 5, {
    pushViewport(viewport(mask = circleGrob()))
    grid.rect(gp = gpar(col = NA, fill = "green"))
    popViewport()
  })

  mask <- xml_find_first(doc, "/svg/defs/mask")
  expect_inherits(mask, "xml_node", info = "mask found")
  id <- xml_attr(mask, "id")
  child <- xml_find_first(mask, ".//circle")
  expect_equal(xml_name(child), "circle", info = "mask child must be the circle")

  rect <- xml_find_first(doc, "/svg/g//rect")
  expect_inherits(rect, "xml_node", info = "rect found")
  maskid <- xml_attr(rect, "mask")
  expect_equal(maskid, paste0("url(#", id, ")"), info = "rect g has correct mask id")
}

# Patterns
{
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
}
