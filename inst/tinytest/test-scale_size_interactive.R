library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# scale_size_interactive ----
{
  eval(test_scale, envir = list(name = "scale_size_interactive"))
  eval(test_scale, envir = list(name = "scale_size_area_interactive"))
  eval(test_scale, envir = list(name = "scale_size_continuous_interactive"))
  eval(test_scale, envir = list(name = "scale_size_discrete_interactive"))
  eval(test_scale, envir = list(name = "scale_size_binned_interactive"))
  eval(test_scale, envir = list(name = "scale_size_binned_area_interactive"))
  eval(test_scale, envir = list(name = "scale_size_date_interactive"))
  eval(test_scale, envir = list(name = "scale_size_datetime_interactive"))
  eval(test_scale, envir = list(name = "scale_size_ordinal_interactive"))
  eval(test_scale, envir = list(name = "scale_radius_interactive"))
}
