library(tinytest)
library(ggiraph)
library(grid)
library(ggplot2)

# encode_cr encodes html entities ----
{
  expect_equal(ggiraph:::encode_cr("&<->"), "&amp;&lt;-&gt;")
}

# encode_cr replaces new line chars with </br> ----
{
  expect_equal(
    ggiraph:::encode_cr(c("\rone\ntwo\r\n", "no newlines")),
    c("&lt;br/&gt;one&lt;br/&gt;two&lt;br/&gt;", "no newlines")
  )
}

# encode_cr does not replace new line chars in html ----
{
  expect_equal(
    ggiraph:::encode_cr("<div>one\ntwo</div>"),
    "&lt;div&gt;one&#10;two&lt;/div&gt;"
  )
  expect_equal(
    ggiraph:::encode_cr(htmltools::HTML("one\ntwo")),
    "one&#10;two"
  )
}

# append_aes is working ----
{
  expect_equal(
    ggiraph:::append_aes(aes("fill" = "black"), list(tooltip = "tooltip")),
    aes(fill = "black", tooltip = "tooltip")
  )
}

# add_default_interactive_aes is working ----
{
  expect_equal(
    unclass(ggiraph:::add_default_interactive_aes(GeomPoint,
      defaults = list(tooltip = NULL, foo = "bar")
    )),
    list(
      shape = 19,
      colour = "black",
      size = 1.5,
      fill = NA,
      alpha = NA,
      stroke = 0.5,
      tooltip = NULL,
      foo = "bar"
    )
  )
}

# grob_argnames is working ----
{
  expect_equal(
    ggiraph:::grob_argnames(list(x = 1, y = 2, tooltip = "tooltip"), pointsGrob),
    c("x", "y")
  )
}

# read_file is working ----
{
  fn <- tempfile()
  tryCatch(
    {
      f <- file(fn, "w")
      cat("line one\n", file = f)
      cat("line two", file = f)
      close(f)
      expect_equal(ggiraph:::read_file(fn), "line one\nline two")
    },
    finally = {
      unlink(fn)
    }
  )
}

# interactive_geom_parameters is working ----
{
  # when geom uses draw_panel
  expect_true(".ipar" %in% ggiraph:::interactive_geom_parameters(geom_point_interactive()$geom))
  # when geom uses draw_group
  expect_true(".ipar" %in% ggiraph:::interactive_geom_parameters(geom_boxplot_interactive()$geom))
  # when geom inherits draw from parent
  expect_true(".ipar" %in% ggiraph:::interactive_geom_parameters(geom_contour_interactive()$geom))
}

# interactive_geom_draw_key is working ----
{
  layer <- geom_point_interactive(aes(tooltip = "tooltip"))
  geom <- layer$geom
  data <- as.data.frame(c(
    ggiraph:::compact(unclass(geom$default_aes)),
    ggiraph:::compact(unclass(layer$mapping))
  ))
  gr <- ggiraph:::interactive_geom_draw_key(geom, data = data, params = geom$parameters(), size = 3)
  expect_identical(ggiraph:::get_interactive_data(gr)$tooltip, "tooltip")
}
