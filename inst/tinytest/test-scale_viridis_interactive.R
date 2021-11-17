library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# scale_viridis_interactive ----
{
  eval(test_scale, envir = list(name = "scale_colour_viridis_d_interactive"))
  eval(test_scale, envir = list(name = "scale_color_viridis_d_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_viridis_d_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_viridis_c_interactive"))
  eval(test_scale, envir = list(name = "scale_color_viridis_c_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_viridis_c_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_viridis_b_interactive"))
  eval(test_scale, envir = list(name = "scale_color_viridis_b_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_viridis_b_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_ordinal_interactive"))
  eval(test_scale, envir = list(name = "scale_color_ordinal_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_ordinal_interactive"))
}
