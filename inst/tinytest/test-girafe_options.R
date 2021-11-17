library(tinytest)
library(ggiraph)

# opts_tooltip ----
{
  opts <- opts_tooltip()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_tooltip is non-empty list")
  expect_error(opts_tooltip(css = "position: relative"), info = "no position in css")
  expect_error(opts_tooltip(css = "pointer-events: none"), info = "no pointer-events in css")
  expect_error(opts_tooltip(opacity = 2), info = "check opacity")
  opts <- opts_tooltip(placement = "auto")
  expect_equal(opts$placement, "doc", info = "check placement")
  options(xaringan.page_number.offset = 0)
  opts <- opts_tooltip(placement = "auto")
  expect_equal(opts$placement, "container", info = "check placement in xarringan")
  options(xaringan.page_number.offset = NULL)
}

# opts_hover ----
{
  opts <- opts_hover()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover is non-empty list")
}
# opts_hover_inv ----
{
  opts <- opts_hover_inv()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover_inv is non-empty list")
}
# opts_hover_key ----
{
  opts <- opts_hover_key()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover_key is non-empty list")
}
# opts_hover_theme ----
{
  opts <- opts_hover_theme()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover_theme is non-empty list")
}

# opts_selection ----
{
  opts <- opts_selection()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection is non-empty list")
  expect_error(opts_selection(type = "mixed"), info = "check type argument")
}
# opts_selection_key ----
{
  opts <- opts_selection_key()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection_key is non-empty list")
  expect_error(opts_selection_key(type = "mixed"), info = "check type argument")
}
# opts_selection_key ----
{
  opts <- opts_selection_theme()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection_theme is non-empty list")
  expect_error(opts_selection_theme(type = "mixed"), info = "check type argument")
}

# opts_zoom ----
{
  opts <- opts_zoom()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_zoom is non-empty list")
  expect_error(opts_zoom(min = "low"), info = "check min argument")
  expect_error(opts_zoom(max = "high"), info = "check max argument")
  expect_error(opts_zoom(max = 0.01), info = "check max argument")
  expect_error(opts_zoom(min = 0.5, max = 0.4), info = "max > min")
}

# opts_toolbar ----
{
  opts <- opts_toolbar()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_toolbar is non-empty list")
  expect_error(opts_toolbar(position = "low"), info = "check position argument")
  expect_error(opts_toolbar(pngname = NULL), info = "check pngname argument")
}

# opts_sizing ----
{
  opts <- opts_sizing()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_sizing is non-empty list")
  expect_error(opts_sizing(rescale = "rescale"), info = "check rescale argument")
  expect_error(opts_sizing(width = "width"), info = "check width argument")
  expect_error(opts_sizing(width = -4), info = "check width range")
}

# default_opts ----
{
  opts <- ggiraph:::default_opts()
  expect_true(is.list(opts) && length(opts) > 0, info = "default_opts is non-empty list")
}

# merge_options ----
{
  opts <- ggiraph:::default_opts()
  new_opts <- list(
    tooltip = opts_tooltip(css = "", offx = 50, offy = 50, use_cursor_pos = FALSE),
    hover = opts_hover(css = "", reactive = TRUE),
    hoverkey = opts_hover_key(css = "", reactive = TRUE),
    hovertheme = opts_hover_theme(css = "", reactive = TRUE),
    hoverinv = opts_hover_inv(css = "opacity: 0.5"),
    zoom = opts_zoom(1, 2),
    capture = opts_selection(css = "", type = "none"),
    capturekey = opts_selection_key(css = "", type = "none"),
    capturetheme = opts_selection_theme(css = "", type = "none"),
    toolbar = opts_toolbar(position = "bottom", pngname = "plot"),
    sizing = opts_sizing(rescale = FALSE)
  )
  opts <- ggiraph:::merge_options(opts, new_opts)
  expect_true(is.list(opts) && length(opts) > 0, info = "merge_options is non-empty list")
  expect_identical(opts, new_opts, info = "merge_options works")
}

# default_sizing_policy ----
{
  opts <- ggiraph:::default_sizing_policy()
  expect_true(is.list(opts) && length(opts) > 0, info = "default_sizing_policy is non-empty list")
}

# merge_sizing_policy ----
{
  policy <- ggiraph:::default_sizing_policy()
  new_policy <- htmlwidgets::sizingPolicy(defaultWidth = 500, defaultHeight = 500)
  policy <- ggiraph:::merge_sizing_policy(policy, list(new_policy))
  expect_true(is.list(opts) && length(opts) > 0, info = "merge_sizing_policy is non-empty list")
  expect_identical(policy, new_policy, info = "merge_sizing_policy works")
}

# girafe_options ----
{
  expect_error(girafe_options("foo"), info = "check x argument")
  g <- girafe({
    NULL
  })
  expect_identical(girafe_options(g), g, info = "no options set")
  result <- girafe_options(g, opts_zoom(1, 5))
  expect_identical(result$x$settings$zoom, opts_zoom(1, 5), info = "zoom options set")
  policy <- htmlwidgets::sizingPolicy(defaultWidth = 500, defaultHeight = 500)
  result <- girafe_options(g, policy)
  expect_identical(result$sizingPolicy, policy, info = "sizingPolicy set")
}
