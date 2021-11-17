library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# annotate_interactive ----
{
  eval(test_annot_layer, envir = list(name = "annotate_interactive"))
}
