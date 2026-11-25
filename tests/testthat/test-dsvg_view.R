# dsvg_view ----
test_that("dsvg_view() is deprecated", {
  rlang::local_options(rlib_warning_verbosity = "verbose")
  expect_warning(v <- dsvg_view(plot(1:10)), "is deprecated")
  if (interactive()) {
    expect_s3_class(v, "html")
  } else {
    expect_null(v)
  }
})
