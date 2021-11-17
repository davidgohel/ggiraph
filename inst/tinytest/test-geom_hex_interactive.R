library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

if (!requireNamespace("hexbin", quietly = TRUE)) {
  exit_file("package 'hexbin' is not installed")
}

# geom_hex_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_hex_interactive"))
}
