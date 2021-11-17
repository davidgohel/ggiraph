library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

if (!requireNamespace("sf", quietly = TRUE)) {
  exit_file("package 'sf' is not installed")
}

# geom_sf_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_sf_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_sf_text_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_sf_label_interactive"))
}
