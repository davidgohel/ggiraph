# animation defaults (set_girafe_defaults(), girafe_defaults()) ----

opts_names <- c(
  "opts_sizing", "opts_tooltip", "opts_hover", "opts_hover_key",
  "opts_hover_theme", "opts_hover_inv", "opts_selection",
  "opts_selection_inv", "opts_selection_key", "opts_selection_theme",
  "opts_zoom", "opts_toolbar"
)

test_that("girafe_defaults() returns every option or one of them", {
  init_girafe_defaults()
  defaults <- girafe_defaults()
  expect_setequal(names(defaults), opts_names)
  for (name in opts_names) {
    expect_s3_class(girafe_defaults(name), name)
  }
  expect_error(girafe_defaults(1), "non-empty scalar character")
  expect_error(girafe_defaults(""), "non-empty scalar character")
})

test_that("defaults set with set_girafe_defaults() are used by girafe()", {
  withr::defer(init_girafe_defaults())
  old <- set_girafe_defaults(
    opts_tooltip = opts_tooltip(offx = 99),
    opts_toolbar = opts_toolbar(position = "top"),
    opts_zoom = opts_zoom(max = 7)
  )
  # the previous defaults are returned
  expect_equal(old$opts_tooltip$offx, 10)

  p <- ggplot(mtcars, aes(wt, mpg)) + geom_point()
  settings <- girafe(ggobj = p)$x$settings
  expect_equal(settings$tooltip$offx, 99)
  expect_equal(settings$toolbar$position, "top")
  expect_equal(settings$zoom$max, 7)

  # options given to girafe() take precedence over the defaults
  settings <- girafe(
    ggobj = p,
    options = list(opts_toolbar(position = "bottom"))
  )$x$settings
  expect_equal(settings$toolbar$position, "bottom")
  expect_equal(settings$tooltip$offx, 99)
})

test_that("init_girafe_defaults() restores the package defaults", {
  init_girafe_defaults()
  pkg_defaults <- girafe_defaults()
  set_girafe_defaults(opts_hover = opts_hover(css = "fill:red;"))
  expect_false(identical(girafe_defaults(), pkg_defaults))
  init_girafe_defaults()
  expect_identical(girafe_defaults(), pkg_defaults)
})

test_that("the fonts argument of set_girafe_defaults() is deprecated", {
  withr::defer(init_girafe_defaults())
  init_girafe_defaults()
  before <- girafe_defaults()
  expect_warning(
    set_girafe_defaults(fonts = list(sans = "Courier New")),
    "deprecated"
  )
  expect_identical(girafe_defaults(), before)
})

test_that("the svg size defaults to 6 x 5 inches outside of knitr", {
  withr::local_options(knitr.in.progress = NULL)
  expect_equal(ggiraph:::default_width(), 6)
  expect_equal(ggiraph:::default_height(), 5)
})
