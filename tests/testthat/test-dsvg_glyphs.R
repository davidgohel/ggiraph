skip_if(ggiraph:::get_ge_version() < 16, "GE >= 16 is required")

font_file <- systemfonts::match_fonts("sans")$path
glyphs <- function(str = "Hello", size = 12) {
  info <- systemfonts::glyph_info(strsplit(str, "")[[1]], path = font_file,
                                  size = size)
  x <- cumsum(c(0, info$x_advance))
  glyphInfo(
    id = info$index,
    x = x[-length(x)],
    y = rep(0, nrow(info)),
    font = rep(1L, nrow(info)),
    size = rep(size, nrow(info)),
    fontList = glyphFontList(glyphFont(font_file, 0L, "sans", 400, "normal")),
    width = glyphWidth(x[length(x)]),
    height = glyphHeight(size)
  )
}

# glyphs are drawn as a single filled path --------------------------------
test_that("glyphs are drawn as a single filled path", {
  doc <- dsvg_doc(grid.draw(glyphGrob(glyphs(), .5, .5,
                                      gp = gpar(col = "darkred"))))
  paths <- xml_find_all(doc, "/svg/g//path")
  expect_equal(length(paths), 1L, info = "one path for the glyph run")
  expect_equal(length(xml_find_all(doc, "//text")), 0L)
  d <- xml_attr(paths[[1]], "d")
  expect_true(nchar(d) > 100, info = "path data is not empty")
  expect_equal(xml_attr(paths[[1]], "fill"), "#8B0000")
  expect_equal(xml_attr(paths[[1]], "stroke"), "none")
})

# the glyph path is an interactive element --------------------------------
test_that("the glyph path is an interactive element", {
  doc <- dsvg_doc({
    grid.newpage()
    ggiraph:::dsvg_tracer_on()
    grid.draw(glyphGrob(glyphs(), .5, .5))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "data-id", ids = ids, values = "g")
  })
  path <- xml_find_first(doc, "/svg/g//path")
  expect_equal(xml_attr(path, "data-id"), "g")
})

# glyphs are part of a stroked or filled path -----------------------------
test_that("glyphs are part of a stroked or filled path", {
  doc <- dsvg_doc(grid.fill(
    gTree(children = gList(rectGrob(), glyphGrob(glyphs(), .5, .5))),
    rule = "evenodd", gp = gpar(fill = "orange")
  ))
  paths <- xml_find_all(doc, "/svg/g//path")
  expect_equal(length(paths), 1L, info = "rectangle and glyphs in one path")
  d <- xml_attr(paths[[1]], "d")
  expect_true(lengths(regmatches(d, gregexpr("M", d))) > 5L,
              info = "rectangle plus glyph contours")
})

# glyphs can be a clipping path -------------------------------------------
test_that("glyphs can be a clipping path", {
  doc <- dsvg_doc({
    pushViewport(viewport(clip = glyphGrob(glyphs(size = 40), .5, .5)))
    grid.rect(gp = gpar(fill = "red", col = NA))
    popViewport()
  })
  clip_path <- xml_find_all(doc, "/svg/defs/clipPath")
  clip_path <- clip_path[[length(clip_path)]]
  child <- xml_child(clip_path)
  expect_equal(xml_name(child), "path")
  expect_true(is.na(xml_attr(child, "fill")), info = "clip path is not painted")
})

# outlines do not depend on the size (no hinting at small sizes) ----------
test_that("outlines do not depend on the size (no hinting at small sizes)", {
  path_points <- function(size) {
    doc <- dsvg_doc(grid.draw(glyphGrob(
      glyphs("a", size = size), x = unit(0, "pt"), y = unit(0, "pt"),
      hjust = 0, vjust = 0
    )))
    d <- xml_attr(xml_find_first(doc, "/svg/g//path"), "d")
    v <- as.numeric(regmatches(d, gregexpr("-?[0-9]+[.]?[0-9]*", d))[[1]])
    m <- matrix(v, ncol = 2, byrow = TRUE)
    sweep(m, 2, m[1, ])
  }
  small <- path_points(10)
  large <- path_points(1000)
  expect_equal(dim(small), dim(large))
  expect_true(max(abs(small * 100 - large)) < 1,
              info = "the 10 pt outline is the 1000 pt outline scaled down")
})

# bitmap glyphs (colour emoji) --------------------------------------------
# colour emoji fonts have no outline: their glyphs are drawn as images.
# Apple Color Emoji on macOS, Noto Color Emoji on Linux (installed on the CI).
emoji_font <- local({
  fonts <- systemfonts::system_fonts()
  fonts[grepl("Color Emoji", fonts$family), c("family", "path", "index")][1, ]
})
skip_if_no_emoji_font <- function() {
  skip_if(is.na(emoji_font$path), "no colour emoji font")
}
# "Hi" in the sans font followed by an emoji in the colour emoji font
mixed_glyphs <- function(emoji = "\U1F600", size = 24) {
  text <- systemfonts::glyph_info(c("H", "i"), path = font_file, size = size)
  emo <- systemfonts::glyph_info(emoji, path = emoji_font$path,
                                 index = emoji_font$index, size = size)
  advances <- c(text$x_advance, emo$x_advance)
  x <- cumsum(c(0, advances))
  glyphInfo(
    id = c(text$index, emo$index),
    x = x[-length(x)],
    y = rep(0, 3),
    font = c(1L, 1L, 2L),
    size = rep(size, 3),
    fontList = glyphFontList(
      glyphFont(font_file, 0L, "sans", 400, "normal"),
      glyphFont(emoji_font$path, emoji_font$index, emoji_font$family, 400,
                "normal")
    ),
    width = glyphWidth(x[length(x)]),
    height = glyphHeight(size)
  )
}

test_that("a colour emoji is drawn as an image", {
  skip_if_no_emoji_font()
  doc <- dsvg_doc(grid.draw(glyphGrob(mixed_glyphs(), .5, .5)))
  images <- xml_find_all(doc, "/svg/g//image")
  expect_length(images, 1L)
  expect_match(xml_attr(images[[1]], "href"), "^data:image/png;base64,")
  paths <- xml_find_all(doc, "/svg/g//path")
  expect_length(paths, 1L)
  d <- xml_attr(paths[[1]], "d")
  expect_true(nchar(d) > 50, info = "the letters are still a path")
})

test_that("the image of a colour emoji follows the size", {
  skip_if_no_emoji_font()
  image_width <- function(size) {
    doc <- dsvg_doc(grid.draw(glyphGrob(mixed_glyphs(size = size), .5, .5)))
    as.numeric(xml_attr(xml_find_first(doc, "/svg/g//image"), "width"))
  }
  small <- image_width(12)
  large <- image_width(48)
  expect_gt(small, 0)
  expect_equal(large / small, 4, tolerance = 0.05)
})

test_that("the image of a colour emoji is rotated with the glyphs", {
  skip_if_no_emoji_font()
  doc <- dsvg_doc(grid.draw(glyphGrob(mixed_glyphs(), .5, .5,
                                      vp = viewport(angle = 30))))
  image <- xml_find_first(doc, "/svg/g//image")
  expect_match(xml_attr(image, "transform"), "rotate\\(-30")
})

test_that("the image of a colour emoji is an interactive element", {
  skip_if_no_emoji_font()
  doc <- dsvg_doc({
    grid.newpage()
    ggiraph:::dsvg_tracer_on()
    grid.draw(glyphGrob(mixed_glyphs(), .5, .5))
    ids <- ggiraph:::dsvg_tracer_off()
    ggiraph:::set_attr(name = "data-id", ids = ids, values = "g")
  })
  expect_equal(xml_attr(xml_find_first(doc, "/svg/g//path"), "data-id"), "g")
  expect_equal(xml_attr(xml_find_first(doc, "/svg/g//image"), "data-id"), "g")
})

test_that("a colour emoji is left out of a clipping path", {
  skip_if_no_emoji_font()
  doc <- dsvg_doc({
    pushViewport(viewport(clip = glyphGrob(mixed_glyphs(size = 40), .5, .5)))
    grid.rect(gp = gpar(fill = "red", col = NA))
    popViewport()
  })
  clip_path <- xml_find_all(doc, "/svg/defs/clipPath")
  clip_path <- clip_path[[length(clip_path)]]
  expect_length(xml_find_all(clip_path, ".//image"), 0L)
  expect_equal(xml_name(xml_child(clip_path)), "path")
})
