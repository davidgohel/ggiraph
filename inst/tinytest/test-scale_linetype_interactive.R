library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# scale_linetype_interactive ----
{
  eval(test_scale, envir = list(name = "scale_linetype_interactive"))
  expect_error(scale_linetype_continuous_interactive())
  eval(test_scale, envir = list(name = "scale_linetype_discrete_interactive"))
  eval(test_scale, envir = list(name = "scale_linetype_binned_interactive"))
}
