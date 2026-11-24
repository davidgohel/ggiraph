errorbarh_data <- data.frame(
  trt = factor(c("a", "b")),
  resp = c(1, 5),
  lower = c(0.5, 4),
  upper = c(1.5, 6)
)

# geom_errorbarh_interactive ----
test_that("geom_errorbarh_interactive() is deprecated", {
  rlang::local_options(rlib_warning_verbosity = "verbose")
  expect_warning(
    geom_errorbarh_interactive(),
    "geom_errorbar_interactive\\(orientation = \"y\"\\)"
  )
})

test_that("geom_errorbarh_interactive() draws horizontal errorbars", {
  rlang::local_options(rlib_warning_verbosity = "quiet")
  base <- ggplot(errorbarh_data, aes(resp, trt, xmin = lower, xmax = upper)) +
    theme_void()
  layer <- geom_errorbarh_interactive(aes(data_id = trt))
  expect_s3_class(layer$geom, "GeomInteractiveErrorbar")
  expect_equal(layer$geom_params$orientation, "y")

  expected <- xml_find_all(dsvg_plot(base + geom_errorbar(orientation = "y")), ".//polyline")
  nodes <- xml_find_all(dsvg_plot(base + layer), ".//polyline")
  expect_equal(xml_attr(nodes, "points"), xml_attr(expected, "points"))
  expect_equal(xml_attr(nodes, "data-id"), rep(c("a", "b"), each = 3))
})

# GeomInteractiveErrorbarh ----
test_that("GeomInteractiveErrorbarh draws as GeomInteractiveErrorbar", {
  base <- ggplot(errorbarh_data, aes(resp, trt, xmin = lower, xmax = upper)) +
    theme_void()
  expected <- xml_find_all(
    dsvg_plot(base + geom_errorbar_interactive(aes(data_id = trt), orientation = "y")),
    ".//polyline"
  )
  nodes <- xml_find_all(
    dsvg_plot(
      base + layer(
        geom = GeomInteractiveErrorbarh, stat = "identity", position = "identity",
        mapping = aes(data_id = trt),
        params = list(orientation = "y", .ipar = ggiraph:::IPAR_NAMES)
      )
    ),
    ".//polyline"
  )
  expect_equal(xml_attr(nodes, "points"), xml_attr(expected, "points"))
  expect_equal(xml_attr(nodes, "data-id"), rep(c("a", "b"), each = 3))
})
