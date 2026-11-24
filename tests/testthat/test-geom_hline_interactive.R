# geom_hline_interactive ----
test_that("geom_hline_interactive", {
  eval(test_geom_layer, envir = list(name = "geom_hline_interactive"))
})

test_that("geom_hline_interactive draws as geom_hline", {
  expect_same_reference_line(
    geom_hline(yintercept = 20),
    geom_hline_interactive(yintercept = 20, data_id = "h"),
    "h"
  )
  expect_same_reference_line(
    geom_hline(yintercept = 20, lineend = "round", linewidth = 3),
    geom_hline_interactive(yintercept = 20, lineend = "round", linewidth = 3, data_id = "h"),
    "h"
  )
})
