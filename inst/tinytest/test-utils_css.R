library(tinytest)
library(ggiraph)

classname_re <- "\\._CLASSNAME_\\s*"
girafe_css_re <- "\\/\\*GIRAFE CSS\\*\\/\\s*"
css_code <- "stroke: black;"
css_re <- function(x) {
  paste0("\\s*\\{\\s*", x, "\\s*\\}\\s*")
}

# validate_css ----
{
  css <- ggiraph:::validate_css(css_code, "text")
  re <- paste0("^", classname_re, css_re(css_code), "$")
  expect_true(grepl(re, css), info = "should return css prefixed with ._CLASSNAME_")

  css <- ggiraph:::validate_css(css_code, "text", "text")
  re <- paste0("^text", classname_re, css_re(css_code), "$")
  expect_true(grepl(re, css), info = "tag name should be used")

  css <- ggiraph:::validate_css(css_code, "text", c("text", "line"))
  re <- paste0("^text", classname_re, ",\\s*line", classname_re, css_re(css_code), "$")
  expect_true(grepl(re, css), info = "multiple tag names should be used")

  expect_equal(
    ggiraph:::validate_css(NULL, "text"), "",
    info = "should return empty css"
  )
  expect_equal(
    ggiraph:::validate_css("", "text"), "",
    info = "should return empty css"
  )

  expect_error(
    ggiraph:::validate_css(c("one", "two"), ""),
    info = "css must be scalar character"
  )
}

# girafe_css ----
{
  expect_equal(
    ggiraph::girafe_css(""),
    "/*GIRAFE CSS*/",
    info = "should return just placeholder /*GIRAFE CSS*/"
  )
  css <- ggiraph::girafe_css(css_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code), "$")
  expect_true(
    grepl(re, css),
    info = "should return the css code with placeholder"
  )
  css_tag_code <- "stroke: none;"
  css <- ggiraph::girafe_css(css_code, text = css_tag_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code))
  re2 <- paste0("\\s*text", classname_re, css_re(css_tag_code), "$")
  expect_true(
    grepl(re, css) && grepl(re2, css),
    info = "should use the tag for text"
  )

  css <- ggiraph::girafe_css(css_code, point = css_tag_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code))
  re2 <- paste0("\\s*circle", classname_re, css_re(css_tag_code), "$")
  expect_true(
    grepl(re, css) && grepl(re2, css),
    info = "should use the tag for point"
  )

  css <- ggiraph::girafe_css(css_code, image = css_tag_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code))
  re2 <- paste0("\\s*image", classname_re, css_re(css_tag_code), "$")
  expect_true(
    grepl(re, css) && grepl(re2, css),
    info = "should use the tag for image"
  )

  css <- ggiraph::girafe_css(css_code, line = css_tag_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code))
  re2 <- paste0(
    "\\s*line", classname_re,
    ",\\s*polyline", classname_re,
    css_re(css_tag_code), "$"
  )
  expect_true(
    grepl(re, css) && grepl(re2, css),
    info = "should use the tags for line"
  )

  css <- ggiraph::girafe_css(css_code, area = css_tag_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code))
  re2 <- paste0(
    "\\s*rect", classname_re,
    ",\\s*polygon", classname_re,
    ",\\s*path", classname_re,
    css_re(css_tag_code), "$"
  )
  expect_true(
    grepl(re, css) && grepl(re2, css),
    info = "should use the tags for area"
  )
}

# check_css ----
{
  default <- "fill:orange;stroke:gray;"
  pattern <- "\\/\\*GIRAFE CSS\\*\\/"
  cls_prefix <- "hover_"
  name <- "opts_hover"
  canvas_id <- "SVGID_"
  expect_error(ggiraph:::check_css(
    c("a", "b"),
    default = default, cls_prefix = cls_prefix, name = name, canvas_id = canvas_id
  ))
  expect_identical(ggiraph:::check_css(
    NULL,
    default = default, cls_prefix = cls_prefix, name = name, canvas_id = canvas_id
  ), paste0(".", cls_prefix, canvas_id, " { ", default, " }"))
}
