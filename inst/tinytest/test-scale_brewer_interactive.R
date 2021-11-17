library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# scale_brewer_interactive ----
{
  eval(test_scale, envir = list(name = "scale_colour_brewer_interactive"))
  eval(test_scale, envir = list(name = "scale_color_brewer_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_brewer_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_distiller_interactive"))
  eval(test_scale, envir = list(name = "scale_color_distiller_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_distiller_interactive"))
  eval(test_scale, envir = list(name = "scale_colour_fermenter_interactive"))
  eval(test_scale, envir = list(name = "scale_color_fermenter_interactive"))
  eval(test_scale, envir = list(name = "scale_fill_fermenter_interactive"))
}
