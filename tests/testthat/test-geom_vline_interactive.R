# geom_vline_interactive ----
test_that("geom_vline_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_vline_interactive"))
})

test_that("geom_vline_interactive draws as geom_vline", {
  expect_same_reference_line(
    geom_vline(xintercept = 3),
    geom_vline_interactive(xintercept = 3, data_id = "v"),
    "v"
  )
  expect_same_reference_line(
    geom_vline(xintercept = 3, lineend = "round", linewidth = 3),
    geom_vline_interactive(xintercept = 3, lineend = "round", linewidth = 3, data_id = "v"),
    "v"
  )
})
