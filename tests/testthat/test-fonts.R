# count the calls listing the system fonts while evaluating `expr`;
# gdtools >= 0.5.2 keeps the list for the session, so it can be 0
count_font_listings <- function(expr) {
  counter <- new.env()
  counter$n <- 0L
  suppressMessages(trace(
    "system_fonts",
    tracer = bquote(assign("n", get("n", envir = .(counter)) + 1L, envir = .(counter))),
    print = FALSE,
    where = asNamespace("gdtools")
  ))
  on.exit(suppressMessages(
    untrace("system_fonts", where = asNamespace("gdtools"))
  ))
  force(expr)
  counter$n
}

fs <- gdtools::font_set_liberation()

# validated_fonts lists the fonts at most once when all families are supplied ----
test_that("validated_fonts lists the fonts at most once when all families are supplied", {
  n <- count_font_listings(fonts <- validated_fonts(fs$dsvg_fonts))
  expect_true(n <= 1L)
  expect_equal(fonts, fs$dsvg_fonts)
})

# validated_fonts completes missing or unknown families ----
test_that("validated_fonts completes missing or unknown families", {
  fonts <- validated_fonts(list(sans = "foo-bar-not-a-font", mono = fs$mono))
  expect_equal(sort(names(fonts)), sort(c("sans", "serif", "mono", "symbol")))
  expect_equal(fonts$sans, fs$sans)
  expect_equal(fonts$serif, fs$serif)
  expect_equal(fonts$mono, fs$mono)
})

# girafe with a font_set lists the fonts at most once ----
test_that("girafe with a font_set lists the fonts at most once", {
  library(ggplot2)
  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point_interactive(aes(tooltip = rownames(mtcars)))
  n <- count_font_listings(girafe(ggobj = p, font_set = fs))
  expect_true(n <= 1L)
})

# font checks in girafe() ----
# the families are read in the SVG, as drawn
svg_fonts <- function(p, ...) {
  # fonts that do not exist: no check of their registration
  ggiraph:::list_svg_fonts(
    girafe(ggobj = p, font_set = fs, check_fonts_registered = FALSE, ...)$x$html
  )
}

test_that("the fonts are read in the SVG, aliases resolved", {
  p <- ggplot(mtcars, aes(wt, mpg, label = cyl)) +
    geom_text(family = "Layer Font") +
    geom_text(family = "mono") +
    labs(title = "title") +
    theme(
      text = element_text(family = "Theme Font"),
      plot.title = element_text(family = ""),
      axis.title = element_text(family = "sans")
    )
  expect_equal(
    svg_fonts(p),
    sort(c("Layer Font", "Theme Font", fs$mono, fs$sans))
  )
})

test_that("the fonts set outside of the plot are read", {
  base <- ggplot(mtcars, aes(wt, mpg, label = cyl)) + geom_text()
  # element_geom() of ggplot2 4.0: the default family of geom_text()
  expect_true("Geom Font" %in% svg_fonts(base + theme(geom = element_geom(family = "Geom Font"))))
  # global theme
  old <- theme_set(theme_minimal(base_family = "Global Font"))
  on.exit(theme_set(old))
  expect_true("Global Font" %in% svg_fonts(base))
  theme_set(old)
  # aesthetic
  p <- ggplot(data.frame(x = 1, y = 1, f = "Mapped Font"), aes(x, y, label = "a", family = f)) +
    geom_text()
  expect_true("Mapped Font" %in% svg_fonts(p))
  # escaped quotes in a name
  expect_equal(
    ggiraph:::list_svg_fonts("<text font-family='It&apos;s'>a</text><text font-family=\"B\">b</text>"),
    c("B", "It's")
  )
})

test_that("a graphic given with `code` is checked", {
  expect_warning(
    girafe(code = plot(1, main = "t", family = "Font That Does Not Exist")),
    "Font That Does Not Exist"
  )
})

test_that("check_fonts_registered warns, by default, on fonts unknown to systemfonts", {
  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme(text = element_text(family = "Font That Does Not Exist"))
  # a warning, the graphic is drawn
  expect_warning(
    x <- girafe(ggobj = p),
    "Font That Does Not Exist"
  )
  expect_s3_class(x, "girafe")
  expect_no_warning(girafe(ggobj = p, check_fonts_registered = FALSE))

  p <- p + theme(text = element_text(family = fs$sans))
  expect_no_warning(girafe(ggobj = p, font_set = fs))
})

test_that("check_fonts_dependencies warns on fonts missing from the dependencies", {
  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme(text = element_text(family = "Font That Does Not Exist"))
  expect_warning(
    girafe(ggobj = p, check_fonts_registered = FALSE, check_fonts_dependencies = TRUE),
    "Font That Does Not Exist"
  )

  # the dependencies of the font set declare the Liberation fonts
  p <- p + theme(text = element_text(family = fs$sans))
  expect_no_warning(
    girafe(ggobj = p, font_set = fs, check_fonts_dependencies = TRUE)
  )
})

test_that("font families are read from the @font-face rules of the dependencies", {
  css <- c(
    "@font-face { font-family: 'Open Sans'; src: url(a.woff2); }",
    "@font-face {",
    "  font-family: \"Roboto\";",
    "  src: url(b.woff2);",
    "}",
    "body { font-family: 'Not A Font Face'; }"
  )
  expect_equal(
    ggiraph:::extract_family_names_regex(css),
    c("Open Sans", "Roboto")
  )
  expect_equal(ggiraph:::extract_family_names_regex("body {}"), character())

  dir <- withr::local_tempdir()
  dir.create(file.path(dir, "css"))
  writeLines(css, file.path(dir, "css", "fonts.css"))
  dep_file <- htmltools::htmlDependency(
    "fonts", "1.0",
    src = c(file = dir), stylesheet = "css/fonts.css"
  )
  dep_chr <- htmltools::htmlDependency(
    "fonts", "1.0",
    src = dir, stylesheet = "css/fonts.css"
  )
  expected <- file.path(dir, "css/fonts.css")
  expect_equal(ggiraph:::htmldep_css_files(dep_file), expected)
  expect_equal(ggiraph:::htmldep_css_files(dep_chr), expected)
  expect_equal(
    ggiraph:::list_families_from_dependencies(list(dep_file)),
    c("Open Sans", "Roboto")
  )
})

test_that("font names without quotes are read", {
  css <- c(
    "@font-face { font-family: Open Sans; src: url(a.woff2); }",
    "@font-face { src: url(b.woff2); font-family: Fira Code }"
  )
  expect_equal(
    ggiraph:::extract_family_names_regex(css),
    c("Fira Code", "Open Sans")
  )
})

test_that("the css files of the dependencies are found as htmltools finds them", {
  # relative to the package
  dep_pkg <- htmltools::htmlDependency(
    "x", "1.0", src = "htmlwidgets", stylesheet = "girafe.yaml", package = "ggiraph"
  )
  expect_equal(
    ggiraph:::htmldep_css_files(dep_pkg),
    file.path(system.file("htmlwidgets", package = "ggiraph"), "girafe.yaml")
  )
  dir <- withr::local_tempdir()
  writeLines("@font-face { font-family: 'Open Sans'; }", file.path(dir, "f.css"))
  # a stylesheet given as a list with href
  dep_list <- htmltools::htmlDependency(
    "x", "1.0", src = dir, stylesheet = list(list(href = "f.css", media = "all"))
  )
  expect_equal(ggiraph:::htmldep_css_files(dep_list), file.path(dir, "f.css"))
  # remote dependency and missing file: nothing to read, no error
  dep_href <- htmltools::htmlDependency(
    "x", "1.0", src = c(href = "https://example.org"), stylesheet = "f.css"
  )
  expect_equal(ggiraph:::htmldep_css_files(dep_href), character())
  dep_missing <- htmltools::htmlDependency("x", "1.0", src = dir, stylesheet = "none.css")
  expect_equal(ggiraph:::htmldep_css_files(dep_missing), character())

  # girafe() does not fail on them
  p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
  expect_s3_class(
    girafe(
      ggobj = p, font_set = fs, check_fonts_dependencies = TRUE,
      dependencies = list(dep_pkg, dep_list, dep_href, dep_missing)
    ),
    "girafe"
  )
})

test_that("font names of the dependencies are compared without case", {
  dir <- withr::local_tempdir()
  writeLines("@font-face { font-family: 'open sans'; }", file.path(dir, "f.css"))
  dep <- htmltools::htmlDependency("x", "1.0", src = dir, stylesheet = "f.css")
  expect_no_warning(
    ggiraph:::fonts_checking_dependencies(list(dep), family_list = "Open Sans")
  )
  expect_warning(
    ggiraph:::fonts_checking_dependencies(list(dep), family_list = "Roboto"),
    "Roboto"
  )
})

# match_family ----
test_that("match_family() is deprecated", {
  # it calls systemfonts::match_font(), deprecated too
  rlang::local_options(lifecycle_verbosity = "quiet")
  expect_warning(family <- match_family("sans"), class = "deprecatedWarning")
  expect_type(family, "character")
})
