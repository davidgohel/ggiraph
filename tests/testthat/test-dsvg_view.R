# dsvg view
test_that("dsvg view", {
  v <- dsvg_view(plot(1:10))
  if (interactive()) {
    expect_s3_class(v, "html")
  } else {
    expect_null(v)
  }
})
