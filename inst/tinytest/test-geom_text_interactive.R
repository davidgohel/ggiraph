library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# geom_text_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_text_interactive"))
}
