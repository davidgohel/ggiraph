library(tinytest)
library(ggiraph)

# opts_tooltip ----
{
  opts <- opts_tooltip()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_tooltip is non-empty list")

  expect_error(opts_tooltip(css = "position: relative"), info = "no position in css")
  expect_error(opts_tooltip(css = "pointer-events: none"), info = "no pointer-events in css")
  expect_error(opts_tooltip(css = 1), info = "check css argument")

  expect_error(opts_tooltip(offx = NULL), info = "check offx argument")
  expect_error(opts_tooltip(offx = "-5"), info = "check offx argument")
  opts <- opts_tooltip(offx = 10)
  expect_equal(opts$offx, 10, info = "check offx argument")

  expect_error(opts_tooltip(offy = NULL), info = "check offy argument")
  expect_error(opts_tooltip(offy = "-5"), info = "check offy argument")
  opts <- opts_tooltip(offy = 10)
  expect_equal(opts$offy, 10, info = "check offy argument")

  expect_error(opts_tooltip(use_cursor_pos = NULL), info = "check use_cursor_pos argument")
  opts <- opts_tooltip(use_cursor_pos = FALSE)
  expect_equal(opts$use_cursor_pos, FALSE, info = "check use_cursor_pos argument")

  expect_error(opts_tooltip(opacity = 2), info = "check opacity argument")
  expect_error(opts_tooltip(opacity = "1"), info = "check opacity argument")
  opts <- opts_tooltip(opacity = 0.5)
  expect_equal(opts$opacity, 0.5, info = "check opacity argument")

  expect_error(opts_tooltip(use_fill = NULL), info = "check use_fill argument")
  opts <- opts_tooltip(use_fill = FALSE)
  expect_equal(opts$use_fill, FALSE, info = "check use_fill argument")

  expect_error(opts_tooltip(use_stroke = NA), info = "check use_stroke argument")
  opts <- opts_tooltip(use_stroke = FALSE)
  expect_equal(opts$use_stroke, FALSE, info = "check use_stroke argument")

  expect_error(opts_tooltip(delay_mouseover = "200"), info = "check delay_mouseover argument")
  expect_error(opts_tooltip(delay_mouseover = -50), info = "check delay_mouseover argument")
  opts <- opts_tooltip(delay_mouseover = 50)
  expect_equal(opts$delay_over, 50, info = "check delay_mouseover argument")

  expect_error(opts_tooltip(delay_mouseout = "200"), info = "check delay_mouseout argument")
  expect_error(opts_tooltip(delay_mouseout = -50), info = "check delay_mouseout argument")
  opts <- opts_tooltip(delay_mouseout = 50)
  expect_equal(opts$delay_out, 50, info = "check delay_mouseout argument")

  opts <- opts_tooltip(placement = "auto")
  expect_equal(opts$placement, "doc", info = "check placement argument")
  options(xaringan.page_number.offset = 0)
  opts <- opts_tooltip(placement = "auto")
  expect_equal(opts$placement, "container", info = "check placement in xarringan")
  options(xaringan.page_number.offset = NULL)
  expect_error(opts_tooltip(placement = "foo"), info = "check placement argument")

  expect_error(opts_tooltip(zindex = "200"), info = "check zindex argument")
  expect_error(opts_tooltip(zindex = 0), info = "check zindex argument")
  opts <- opts_tooltip(zindex = 50.4)
  expect_true(grepl("z-index:50", opts$css), info = "check zindex argument")
}

# opts_hover ----
{
  opts <- opts_hover()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover is non-empty list")

  expect_error(opts_hover(reactive = NA), info = "check reactive argument")
  opts <- opts_hover(reactive = FALSE)
  expect_equal(opts$reactive, FALSE, info = "check reactive argument")

  expect_error(opts_hover(nearest_distance = "200"), info = "check nearest_distance argument")
  expect_error(opts_hover(nearest_distance = -50), info = "check nearest_distance argument")
  opts <- opts_hover(nearest_distance = 50)
  expect_equal(opts$nearest_distance, 50, info = "check nearest_distance argument")
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

  expect_error(opts_hover_key(reactive = NA), info = "check reactive argument")
  opts <- opts_hover_key(reactive = FALSE)
  expect_equal(opts$reactive, FALSE, info = "check reactive argument")
}
# opts_hover_theme ----
{
  opts <- opts_hover_theme()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover_theme is non-empty list")

  expect_error(opts_hover_theme(reactive = NA), info = "check reactive argument")
  opts <- opts_hover_theme(reactive = FALSE)
  expect_equal(opts$reactive, FALSE, info = "check reactive argument")
}

# opts_selection ----
{
  opts <- opts_selection()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection is non-empty list")

  expect_error(opts_selection(type = "mixed"), info = "check type argument")
  opts <- opts_selection(type = "single")
  expect_equal(opts$type, "single", info = "check type argument")

  expect_error(opts_selection(only_shiny = NA), info = "check only_shiny argument")
  opts <- opts_selection(only_shiny = FALSE)
  expect_equal(opts$only_shiny, FALSE, info = "check only_shiny argument")

  opts <- opts_selection(selected = 1)
  expect_equal(opts$selected, "1", info = "check selected argument")
}
# opts_selection_inv ----
{
  opts <- opts_selection_inv()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection_inv is non-empty list")
}
# opts_selection_key ----
{
  opts <- opts_selection_key()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection_key is non-empty list")

  expect_error(opts_selection_key(type = "mixed"), info = "check type argument")
  opts <- opts_selection_key(type = "single")
  expect_equal(opts$type, "single", info = "check type argument")

  expect_error(opts_selection_key(only_shiny = NA), info = "check only_shiny argument")
  opts <- opts_selection_key(only_shiny = FALSE)
  expect_equal(opts$only_shiny, FALSE, info = "check only_shiny argument")

  opts <- opts_selection_key(selected = 1)
  expect_equal(opts$selected, "1", info = "check selected argument")
}
# opts_selection_theme ----
{
  opts <- opts_selection_theme()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection_theme is non-empty list")

  expect_error(opts_selection_theme(type = "mixed"), info = "check type argument")
  opts <- opts_selection_theme(type = "single")
  expect_equal(opts$type, "single", info = "check type argument")

  expect_error(opts_selection_theme(only_shiny = NA), info = "check only_shiny argument")
  opts <- opts_selection_theme(only_shiny = FALSE)
  expect_equal(opts$only_shiny, FALSE, info = "check only_shiny argument")

  opts <- opts_selection_theme(selected = 1)
  expect_equal(opts$selected, "1", info = "check selected argument")
}

# opts_zoom ----
{
  opts <- opts_zoom()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_zoom is non-empty list")

  expect_error(opts_zoom(min = "low"), info = "check min argument")
  expect_error(opts_zoom(min = 0.01), info = "check min argument")
  opts <- opts_zoom(min = 1)
  expect_equal(opts$min, 1, info = "check min argument")

  expect_error(opts_zoom(max = "high"), info = "check max argument")
  expect_error(opts_zoom(max = 0.01), info = "check max argument")
  opts <- opts_zoom(max = 1)
  expect_equal(opts$max, 1, info = "check max argument")

  expect_error(opts_zoom(min = 0.5, max = 0.4), info = "max > min")

  expect_error(opts_zoom(duration = "200"), info = "check duration argument")
  expect_error(opts_zoom(duration = -50), info = "check duration argument")
  opts <- opts_zoom(duration = 50)
  expect_equal(opts$duration, 50, info = "check duration argument")
}

# opts_toolbar ----
{
  opts <- opts_toolbar()
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_toolbar is non-empty list")

  expect_error(opts_toolbar(position = "low"), info = "check position argument")
  opts <- opts_toolbar(position = "top")
  expect_equal(opts$position, "top", info = "check position argument")

  expect_error(opts_toolbar(pngname = NULL), info = "check pngname argument")
  opts <- opts_toolbar(pngname = "foo")
  expect_equal(opts$pngname, "foo", info = "check pngname argument")

  expect_error(opts_toolbar(tooltips = "b"), info = "check tooltips argument")
  expect_error(opts_toolbar(tooltips = list("b")), info = "check tooltips argument")
  opts <- opts_toolbar(tooltips = list("a"="b"))
  expect_equal(opts$tooltips, list("a"="b"), info = "check tooltips argument")

  expect_error(opts_toolbar(saveaspng = NA), info = "check saveaspng argument")
  expect_error(opts_toolbar(hidden = TRUE), info = "check hidden argument")
  opts <- opts_toolbar(hidden = "selection")
  expect_equal(opts$hidden, "selection", info = "check hidden argument")
  opts <- opts_toolbar(saveaspng = FALSE)
  expect_equal(opts$hidden, "saveaspng", info = "check saveaspng/hidden argument")

  expect_error(opts_toolbar(delay_mouseover = "200"), info = "check delay_mouseover argument")
  expect_error(opts_toolbar(delay_mouseover = -50), info = "check delay_mouseover argument")
  opts <- opts_toolbar(delay_mouseover = 50)
  expect_equal(opts$delay_over, 50, info = "check delay_mouseover argument")

  expect_error(opts_toolbar(delay_mouseout = "200"), info = "check delay_mouseout argument")
  expect_error(opts_toolbar(delay_mouseout = -50), info = "check delay_mouseout argument")
  opts <- opts_toolbar(delay_mouseout = 50)
  expect_equal(opts$delay_out, 50, info = "check delay_mouseout argument")
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
    hover_inv = opts_hover_inv(css = "opacity: 0.5"),
    hover_key = opts_hover_key(css = "", reactive = TRUE),
    hover_theme = opts_hover_theme(css = "", reactive = TRUE),
    select = opts_selection(css = "", type = "none"),
    select_inv = opts_selection_inv(css = "opacity: 0.5"),
    select_key = opts_selection_key(css = "", type = "none"),
    select_theme = opts_selection_theme(css = "", type = "none"),
    zoom = opts_zoom(1, 2),
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
  expect_error(opts_hover(nearest_distance = "50"), info = "nearest_distance")
  expect_error(opts_hover(nearest_distance = -15), info = "nearest_distance")
}
