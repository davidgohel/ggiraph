library(tinytest)
library(ggiraph)
library(ggplot2)

# find_interactive_class ----
{
  expect_inherits(ggiraph:::find_interactive_class("histogram"), "Geom")
  expect_inherits(ggiraph:::find_interactive_class(GeomBoxplot), "Geom")
  expect_error(ggiraph:::find_interactive_class(FALSE))
  expect_error(ggiraph:::find_interactive_class("foo"))
}

# layer_interactive argument interactive_geom ----
{
  result <- ggiraph:::layer_interactive(geom_count, interactive_geom = GeomInteractivePoint)
  expect_identical(result$geom, GeomInteractivePoint)
}
