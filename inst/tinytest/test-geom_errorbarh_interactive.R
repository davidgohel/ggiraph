library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# geom_errorbarh_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_errorbarh_interactive"))
}
