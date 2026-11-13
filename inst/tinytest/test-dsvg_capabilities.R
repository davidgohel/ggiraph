library(tinytest)
library(ggiraph)
library(grid)
source("setup.R")

if (ggiraph:::get_ge_version() < 15) {
  exit_file("GE >= 15 is required")
}

# dev.capabilities() reports what dsvg draws ------------------------------
{
  file <- tempfile(fileext = ".svg")
  dsvg(file = file)
  capa <- grDevices::dev.capabilities()
  dev.off()
  unlink(file)

  expect_equal(
    capa$patterns,
    c("LinearGradient", "RadialGradient", "TilingPattern"),
    info = "gradients and tiling patterns"
  )
  expect_true(capa$clippingPaths, info = "clipping paths")
  expect_equal(capa$masks, c("alpha", "luminance"), info = "both mask types")
  expect_equal(length(capa$compositing), 24L, info = "all operators but one")
  expect_false("saturate" %in% capa$compositing, info = "saturate not supported")
  expect_true(capa$transformations, info = "group transformations")
  expect_true(capa$paths, info = "path stroking and filling")
  expect_equal(capa$glyphs, ggiraph:::get_ge_version() >= 16, info = "glyphs")
}

# luminance masks are not drawn as alpha masks ---------------------------
{
  mask_doc <- function(type) {
    dsvg_doc({
      pushViewport(viewport(mask = as.mask(circleGrob(), type = type)))
      grid.rect(gp = gpar(col = NA, fill = "red"))
      popViewport()
    })
  }
  doc <- mask_doc("luminance")
  mask <- xml_find_first(doc, "/svg/defs/mask")
  expect_equal(xml_attr(mask, "style"), "mask-type:luminance")
  expect_equal(length(xml_find_all(doc, "/svg/defs/filter")), 0L,
               info = "no alpha filter")
  expect_true(all(is.na(xml_attr(xml_find_all(mask, ".//*"), "filter"))),
              info = "mask content is not filtered")

  doc <- mask_doc("alpha")
  mask <- xml_find_first(doc, "/svg/defs/mask")
  expect_true(is.na(xml_attr(mask, "style")))
  filter_id <- xml_attr(xml_find_first(doc, "/svg/defs/filter"), "id")
  expect_equal(xml_attr(xml_child(mask), "filter"),
               paste0("url(#", filter_id, ")"), info = "alpha filter applied")
}
