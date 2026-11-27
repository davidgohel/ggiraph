classname_re <- "\\._CLASSNAME_\\s*"
girafe_css_re <- "\\/\\*GIRAFE CSS\\*\\/\\s*"
css_code <- "stroke: black;"
css_re <- function(x) {
  paste0("\\s*\\{\\s*", x, "\\s*\\}\\s*")
}

# validate_css ----
test_that("validate_css", {
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
})

# girafe_css ----
test_that("girafe_css", {
  expect_equal(
    ggiraph::girafe_css(""),
    "/*GIRAFE CSS*/",
    info = "should return just placeholder /*GIRAFE CSS*/"
  )
  css <- ggiraph::girafe_css(css_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code))
  expect_true(
    grepl(re, css),
    info = "should return the css code with placeholder"
  )
  css_tag_code <- "stroke: none;"
  css <- ggiraph::girafe_css(css_code, text = css_tag_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code))
  re2 <- paste0("\\s*text", classname_re, css_re(css_tag_code))
  expect_true(
    grepl(re, css) && grepl(re2, css),
    info = "should use the tag for text"
  )

  css <- ggiraph::girafe_css(css_code, point = css_tag_code)
  re <- paste0("^", girafe_css_re, classname_re, css_re(css_code))
  re2 <- paste0("\\s*circle", classname_re, css_re(css_tag_code))
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
})

# check_css ----
test_that("check_css", {
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
  ), paste0(
    ".", cls_prefix, canvas_id, " { ", default, " }\n",
    # a raw css does not fill the lines
    "line.", cls_prefix, canvas_id, ", polyline.", cls_prefix, canvas_id, " { fill:none; }"
  ))
})

test_that("girafe_css_bicolor", {
  expect_equal(
    girafe_css_bicolor(primary = "yellow", secondary = "black"),
    girafe_css(
      css = "fill:yellow;stroke:black;cursor:pointer;",
      text = "stroke:none;fill:yellow;",
      line = "fill:none;stroke:yellow;",
      area = "fill:yellow;stroke:none;",
      point = "fill:yellow;stroke:black;",
      image = "stroke:yellow;"
    )
  )
})

# lines are not filled unless asked ----
test_that("girafe_css does not fill lines, unless asked with `line`", {
  no_fill <- "line._CLASSNAME_, polyline._CLASSNAME_ { fill:none; }"
  # a generic css with a fill would fill the polylines as closed shapes
  expect_equal(
    ggiraph::girafe_css("fill:orange;stroke:orange;"),
    paste0("/*GIRAFE CSS*/._CLASSNAME_ { fill:orange;stroke:orange; }\n", no_fill)
  )
  # an explicit line rule is kept as it is
  css <- ggiraph::girafe_css("fill:orange;", line = "fill:red;")
  expect_false(grepl("fill:none", css, fixed = TRUE))
  expect_true(grepl("polyline._CLASSNAME_ { fill:red; }", css, fixed = TRUE))
  # an empty css stays empty (no style, e.g. no inverted hover)
  expect_equal(ggiraph::girafe_css(""), "/*GIRAFE CSS*/")
  # a css without fill stays as it is: the lines are not filled anyway
  expect_equal(
    ggiraph::girafe_css("stroke:red;stroke-width:2.5px;"),
    "/*GIRAFE CSS*/._CLASSNAME_ { stroke:red;stroke-width:2.5px; }"
  )
  expect_false(grepl("fill", settings_with(opts_selection(css = "stroke:red;r:3.5px;"))$select$css, fixed = TRUE))
  # fill-opacity is a fill
  expect_true(grepl(no_fill, ggiraph::girafe_css("fill-opacity:0.5;"), fixed = TRUE))
})

test_that("the tooltip css is a single rule (no rule for lines)", {
  css <- settings_with(opts_tooltip(css = "background:black;"))$tooltip$css
  expect_false(grepl("polyline", css, fixed = TRUE))
  # the declarations managed by girafe end the tooltip rule
  expect_equal(
    css,
    ".tooltip_SVGID_ { background:black; ; position:absolute;pointer-events:none;z-index:9999;}"
  )
})
