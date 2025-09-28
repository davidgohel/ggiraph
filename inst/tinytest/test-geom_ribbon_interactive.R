library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)
source("setup.R")

set.seed(2)
n <- 6
tt <- data.frame(
  y = sort(rnorm(n)),
  z = rep(c(1, 2), length.out = n)
)
tt[tt$z == 2, "y"] <- tt[tt$z == 2, "y"] * 2
tt$x <- seq_len(n)
tt$z <- factor(tt$z, 1:2, letters[1:2])


# geom_ribbon_interactive ----
{
  eval(test_geom_layer, envir = list(name = "geom_ribbon_interactive"))
  eval(test_geom_layer, envir = list(name = "geom_area_interactive"))
}

# polygons and polylines have the correct data-id ----
{
  doc <- dsvg_doc(pointsize = 10, {
    gg <- ggplot(data = tt, aes(x = x, y = y, group = z, color = z, data_id = z)) +
      geom_line_interactive(show.legend = FALSE) +
      geom_ribbon_interactive(aes(ymin = y - 0.4, ymax = y + 0.4), alpha = 0.2, show.legend = FALSE) +
      theme_void()
    print(gg)
  })

  polygons_a <- xml_find_all(doc, ".//polygon[@data-id='a']")
  expect_length(polygons_a, 1)
  polylines_a <- xml_find_all(doc, ".//polyline[@data-id='a']")
  expect_length(polylines_a, 3)

  polygons_b <- xml_find_all(doc, ".//polygon[@data-id='b']")
  expect_length(polygons_b, 1)
  polylines_b <- xml_find_all(doc, ".//polyline[@data-id='b']")
  expect_length(polylines_b, 3)
}
