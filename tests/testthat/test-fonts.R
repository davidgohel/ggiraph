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
test_that("font checks warn when there is no ggplot to read the fonts from", {
  expect_warning(
    girafe(code = plot(1), check_fonts_registered = TRUE),
    "Fonts can not be checked"
  )
  expect_warning(
    girafe(code = plot(1), check_fonts_dependencies = TRUE),
    "Fonts can not be checked"
  )
})

test_that("list_fonts() reads the fonts of the theme and of the layers", {
  p <- ggplot(mtcars, aes(wt, mpg, label = cyl)) +
    geom_text(family = "Layer Font") +
    geom_text(family = "sans") +
    theme(
      text = element_text(family = "Theme Font"),
      plot.title = element_text(family = ""),
      axis.title = element_text(family = "mono")
    )
  # generic families are not checked
  expect_equal(ggiraph:::list_fonts(p), c("Layer Font", "Theme Font"))
  expect_equal(ggiraph:::list_fonts(ggplot()), character())
})

test_that("check_fonts_registered stops on fonts unknown to systemfonts", {
  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme(text = element_text(family = "Font That Does Not Exist"))
  expect_error(
    girafe(ggobj = p, check_fonts_registered = TRUE),
    "Font That Does Not Exist"
  )

  p <- p + theme(text = element_text(family = fs$sans))
  expect_s3_class(
    girafe(ggobj = p, font_set = fs, check_fonts_registered = TRUE),
    "girafe"
  )
})

test_that("check_fonts_dependencies warns on fonts missing from the dependencies", {
  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme(text = element_text(family = "Font That Does Not Exist"))
  expect_warning(
    girafe(ggobj = p, check_fonts_dependencies = TRUE),
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

# match_family ----
test_that("match_family() is deprecated", {
  # it calls systemfonts::match_font(), deprecated too
  rlang::local_options(lifecycle_verbosity = "quiet")
  expect_warning(family <- match_family("sans"), class = "deprecatedWarning")
  expect_type(family, "character")
})
