# scale_shape_interactive ----
test_that("scale_shape_interactive", {
  eval(test_scale, envir = list(name = "scale_shape_interactive"))
  expect_error(scale_shape_continuous_interactive())
  eval(test_scale, envir = list(name = "scale_shape_discrete_interactive"))
  eval(test_scale, envir = list(name = "scale_shape_binned_interactive"))
  eval(test_scale, envir = list(name = "scale_shape_ordinal_interactive"))
})
