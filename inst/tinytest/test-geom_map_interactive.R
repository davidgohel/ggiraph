library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

if (!requireNamespace("maps", quietly = TRUE)) {
  exit_file("package 'maps' is not installed")
}

# geom_map_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_map_interactive"))
}
