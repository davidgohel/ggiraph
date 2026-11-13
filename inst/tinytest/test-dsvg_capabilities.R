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
  expect_equal(capa$masks, "alpha", info = "alpha masks only")
  expect_false(capa$compositing, info = "no groups")
  expect_false(capa$transformations, info = "no group transformations")
  expect_false(capa$paths, info = "no path stroking or filling")
  expect_false(capa$glyphs, info = "no glyphs")
}

# unsupported features warn instead of being silently dropped -----------
{
  expect_warning(
    dsvg_doc(grid.stroke(circleGrob(r = .2))),
    pattern = "Stroking a path is not supported"
  )
  expect_warning(
    dsvg_doc(grid.fill(circleGrob(r = .2), gp = gpar(fill = "green"))),
    pattern = "Filling a path is not supported"
  )
  expect_warning(
    dsvg_doc(grid.fillStroke(circleGrob(r = .2), gp = gpar(fill = "green"))),
    pattern = "Filling and stroking a path is not supported"
  )
  expect_warning(
    dsvg_doc(grid.group(circleGrob(r = .3), "xor", rectGrob())),
    pattern = "Group definition failed"
  )
}
