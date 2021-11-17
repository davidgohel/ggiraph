library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# scale_alpha_interactive ----
{
  eval(test_scale, envir = list(name = "scale_alpha_interactive"))
  eval(test_scale, envir = list(name = "scale_alpha_continuous_interactive"))
  eval(test_scale, envir = list(name = "scale_alpha_discrete_interactive"))
  eval(test_scale, envir = list(name = "scale_alpha_binned_interactive"))
  eval(test_scale, envir = list(name = "scale_alpha_ordinal_interactive"))
  eval(test_scale, envir = list(name = "scale_alpha_date_interactive"))
  eval(test_scale, envir = list(name = "scale_alpha_datetime_interactive"))
}
