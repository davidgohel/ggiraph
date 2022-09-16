library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

# geom_point_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_point_interactive"))
}

# hover_nearest ---
{
  gr <- ggplot(mtcars, aes(x =mpg, y = disp, hover_nearest = TRUE)) +
    geom_point_interactive()
  doc <- dsvg_doc({
    print(gr)
  })

  expect_equal(xml_attr(xml_find_first(doc, ".//circle"), "nearest"), "true")
}
