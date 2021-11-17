library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# scale_steps_interactive ----
{
  eval(test_scale, envir = list(name = "scale_colour_steps_interactive"))
  eval(test_scale, envir = list(name = "scale_color_steps_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_steps_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_steps2_interactive"))
  eval(test_scale, envir = list(name = "scale_color_steps2_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_steps2_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_stepsn_interactive"))
  eval(test_scale, envir = list(name = "scale_color_stepsn_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_stepsn_interactive"))
}
