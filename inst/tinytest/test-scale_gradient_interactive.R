library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# scale_gradient_interactive ----
{
  eval(test_scale, envir = list(name = "scale_colour_gradient_interactive"))
  eval(test_scale, envir = list(name = "scale_color_gradient_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_gradient_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_gradient2_interactive"))
  eval(test_scale, envir = list(name = "scale_color_gradient2_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_gradient2_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_gradientn_interactive"))
  eval(test_scale, envir = list(name = "scale_color_gradientn_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_gradientn_interactive"))
}
