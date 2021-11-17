library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# scale_manual_interactive ----
{
  eval(test_scale, envir = list(name = "scale_colour_manual_interactive"))
  eval(test_scale, envir = list(name = "scale_color_manual_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_manual_interactive"))
  eval(test_scale, envir = list(name = "scale_size_manual_interactive"))
  eval(test_scale, envir = list(name = "scale_shape_manual_interactive"))
  eval(test_scale, envir = list(name = "scale_linetype_manual_interactive"))
  eval(test_scale, envir = list(name = "scale_alpha_manual_interactive"))
  eval(test_scale, envir = list(name = "scale_discrete_manual_interactive"))
}
