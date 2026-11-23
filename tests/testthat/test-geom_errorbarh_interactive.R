# geom_errorbarh_interactive ----
test_that("geom_errorbarh_interactive", {
  # geom_errorbarh() is deprecated since ggplot2 4.0.0
  rlang::local_options(lifecycle_verbosity = "quiet")
  eval(test_geom_layer, envir = list(name = "geom_errorbarh_interactive"))
})
