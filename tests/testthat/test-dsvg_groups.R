skip_if(ggiraph:::get_ge_version() < 15, "GE >= 15 is required")

src <- circleGrob(x = .6, r = .2, gp = gpar(fill = "blue"))
dst <- rectGrob(x = .4, width = .4, height = .4, gp = gpar(fill = "red"))
group_doc <- function(op, dst = NULL) {
  dsvg_doc(grid.group(src, op, dst))
}
# the <use> elements composing the group
parts <- function(doc) {
  group_id <- sub("^#", "", xml_attr(xml_find_first(doc, "/svg/g//use"), "href"))
  group <- xml_find_first(doc, sprintf("/svg/defs/g[@id='%s']", group_id))
  list(group = group, uses = xml_find_all(group, "use"))
}
href_id <- function(x) sub("^#", "", xml_attr(x, "href"))

# a group is defined in the defs and drawn with <use> ---------------------
test_that("a group is defined in the defs and drawn with <use>", {
  doc <- group_doc("over", dst)
  p <- parts(doc)
  expect_s3_class(p$group, "xml_node")
  expect_equal(xml_attr(p$group, "style"), "isolation:isolate")
  expect_equal(length(p$uses), 2L, info = "destination then source")
  layers <- vapply(p$uses, href_id, "")
  dst_layer <- xml_find_first(doc, sprintf("/svg/defs/g[@id='%s']", layers[1]))
  src_layer <- xml_find_first(doc, sprintf("/svg/defs/g[@id='%s']", layers[2]))
  expect_equal(length(xml_find_all(dst_layer, ".//rect")), 1L)
  expect_equal(length(xml_find_all(src_layer, ".//circle")), 1L)
  expect_equal(length(xml_find_all(doc, "/svg/g//circle")), 0L,
               info = "shapes are only drawn through the group")
})

# blend modes use mix-blend-mode on the source ----------------------------
test_that("blend modes use mix-blend-mode on the source", {
  p <- parts(group_doc("multiply", dst))
  expect_equal(xml_attr(p$uses[[2]], "style"), "mix-blend-mode:multiply")
  p <- parts(group_doc("color.dodge", dst))
  expect_equal(xml_attr(p$uses[[2]], "style"), "mix-blend-mode:color-dodge")
})

test_that("each blend mode of grid has its CSS name", {
  modes <- c(
    multiply = "multiply", screen = "screen", overlay = "overlay",
    darken = "darken", lighten = "lighten",
    color.dodge = "color-dodge", color.burn = "color-burn",
    hard.light = "hard-light", soft.light = "soft-light",
    difference = "difference", exclusion = "exclusion"
  )
  for (op in names(modes)) {
    p <- parts(group_doc(op, dst))
    expect_equal(length(p$uses), 2L, info = op)
    expect_equal(xml_attr(p$uses[[2]], "style"),
                 paste0("mix-blend-mode:", modes[[op]]), info = op)
  }
})

# Porter-Duff operators use masks of the other layer ----------------------
test_that("Porter-Duff operators use masks of the other layer", {
  doc <- group_doc("in", dst)
  p <- parts(doc)
  expect_equal(length(p$uses), 1L)
  mask_id <- sub("^url\\(#(.*)\\)$", "\\1", xml_attr(p$uses[[1]], "mask"))
  mask <- xml_find_first(doc, sprintf("/svg/defs/mask[@id='%s']", mask_id))
  expect_equal(length(xml_find_all(mask, "rect")), 0L, info = "alpha mask")
  expect_true(grepl("_d$", href_id(xml_find_first(mask, "use"))),
              info = "mask made of the destination")

  doc <- group_doc("out", dst)
  p <- parts(doc)
  mask_id <- sub("^url\\(#(.*)\\)$", "\\1", xml_attr(p$uses[[1]], "mask"))
  mask <- xml_find_first(doc, sprintf("/svg/defs/mask[@id='%s']", mask_id))
  expect_equal(length(xml_find_all(mask, "rect")), 1L,
               info = "inverse alpha mask starts with a white rectangle")
  filter_id <- sub("^url\\(#(.*)\\)$", "\\1",
                   xml_attr(xml_find_first(mask, "use"), "filter"))
  expect_true(grepl("_filter_black$", filter_id))
})

# dest.* operators swap the layers --------------------------------------
test_that("dest.over, dest.in and dest.out swap source and destination", {
  p <- parts(group_doc("dest.over", dst))
  expect_equal(sub(".*_", "", vapply(p$uses, href_id, "")), c("s", "d"),
               info = "source under the destination")
  expect_true(all(is.na(xml_attr(p$uses, "mask"))))

  p <- parts(group_doc("dest.in", dst))
  expect_equal(length(p$uses), 1L)
  expect_true(grepl("_d$", href_id(p$uses[[1]])))
  expect_match(xml_attr(p$uses[[1]], "mask"), "_s_a\\)$",
               info = "destination masked by the alpha of the source")

  p <- parts(group_doc("dest.out", dst))
  expect_equal(length(p$uses), 1L)
  expect_true(grepl("_d$", href_id(p$uses[[1]])))
  expect_match(xml_attr(p$uses[[1]], "mask"), "_s_ia\\)$",
               info = "destination masked by the inverse alpha of the source")
})

# sums are added with plus-lighter -----------------------------------------
test_that("sums are added with plus-lighter", {
  for (op in c("atop", "dest.atop", "xor", "add")) {
    p <- parts(group_doc(op, dst))
    expect_equal(length(p$uses), 2L, info = op)
    expect_equal(xml_attr(p$uses[[2]], "style"), "mix-blend-mode:plus-lighter",
                 info = op)
  }
})

# clear, source, dest ------------------------------------------------------
test_that("clear, source, dest", {
  doc <- group_doc("clear", dst)
  expect_equal(length(parts(doc)$uses), 0L, info = "clear draws nothing")
  expect_equal(length(xml_find_all(doc, "/svg/defs/g[substring(@id, string-length(@id) - 1) = '_s' or substring(@id, string-length(@id) - 1) = '_d']")), 0L,
               info = "clear does not define the layers")
  p <- parts(group_doc("source", dst))
  expect_equal(length(p$uses), 1L)
  expect_true(grepl("_s$", href_id(p$uses[[1]])))
  p <- parts(group_doc("dest", dst))
  expect_equal(length(p$uses), 1L)
  expect_true(grepl("_d$", href_id(p$uses[[1]])))
})

# without destination ------------------------------------------------------
test_that("without destination", {
  p <- parts(group_doc("in"))
  expect_equal(length(p$uses), 0L, info = "source in nothing is nothing")
  p <- parts(group_doc("out"))
  expect_equal(length(p$uses), 1L, info = "source out of nothing is the source")
  expect_true(is.na(xml_attr(p$uses[[1]], "mask")))
})

# saturate is drawn as over, with a warning -------------------------------
test_that("saturate is drawn as over, with a warning", {
  expect_warning(doc <- group_doc("saturate", dst), regexp = "saturate")
  expect_equal(length(parts(doc)$uses), 2L)
})

# groups are drawn with the transformation of the viewport ----------------
test_that("groups are drawn with the transformation of the viewport", {
  doc <- dsvg_doc({
    grid.define(rectGrob(width = .2, height = .2), name = "motif")
    pushViewport(viewport(angle = 30))
    grid.use("motif")
    popViewport()
  })
  use <- xml_find_first(doc, "/svg/g//use")
  expect_true(grepl("^matrix\\(", xml_attr(use, "transform")))
})

# the group is an interactive element ------------------------------------
test_that("the group is an interactive element", {
  doc <- dsvg_doc({
    grid.newpage()
    ggiraph:::dsvg_tracer_on()
    grid.group(src, "over", dst)
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "data-id", ids = ids, values = "grp")
  })
  expect_equal(xml_attr(xml_find_first(doc, "/svg/g//use"), "data-id"), "grp")
})
