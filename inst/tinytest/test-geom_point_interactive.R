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

# test all shapes ----
{
  doc <- dsvg_doc({
    sxy <- seq(from = 0.2, to = 0.95, by = 0.15)
    s <- seq.int(from = 0, to = 25)
    dat <- data.frame(
      x = head(rep(sxy, 5), length(s)),
      y = head(rep(sxy, each = 6), length(s)),
      s = s
    )
    p <- ggplot(dat, aes(x =x, y = y, shape = I(s), col=as.character(s), tooltip = s, info= s)) +
      geom_point_interactive(extra_interactive_params = "info")
    print(p)
  })

  for (i in s) {
    nodes <- xml_find_all(doc, paste0(".//*[@info='", i, "']"))
    expect_true(length(nodes) > 0, info = paste("Shape", i, "is drawn"))
  }
}

{
  gr <- ggiraph:::partialPointGrob(interactive_points_grob(), pch = 2)
  expect_true(ggiraph:::is.zero(gr))
}
