# opts_tooltip ----
test_that("opts_tooltip", {
  opts <- settings_with(opts_tooltip())$tooltip
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_tooltip is non-empty list")

  expect_error(opts_tooltip(css = "position: relative"), info = "no position in css")
  expect_error(opts_tooltip(css = "pointer-events: none"), info = "no pointer-events in css")
  expect_error(opts_tooltip(css = 1), info = "check css argument")

  expect_error(opts_tooltip(offx = NULL), info = "check offx argument")
  expect_error(opts_tooltip(offx = "-5"), info = "check offx argument")
  opts <- settings_with(opts_tooltip(offx = 10))$tooltip
  expect_equal(opts$offx, 10, info = "check offx argument")

  expect_error(opts_tooltip(offy = NULL), info = "check offy argument")
  expect_error(opts_tooltip(offy = "-5"), info = "check offy argument")
  opts <- settings_with(opts_tooltip(offy = 10))$tooltip
  expect_equal(opts$offy, 10, info = "check offy argument")

  expect_error(opts_tooltip(use_cursor_pos = NULL), info = "check use_cursor_pos argument")
  opts <- settings_with(opts_tooltip(use_cursor_pos = FALSE))$tooltip
  expect_equal(opts$use_cursor_pos, FALSE, info = "check use_cursor_pos argument")

  expect_error(opts_tooltip(opacity = 2), info = "check opacity argument")
  expect_error(opts_tooltip(opacity = "1"), info = "check opacity argument")
  opts <- settings_with(opts_tooltip(opacity = 0.5))$tooltip
  expect_equal(opts$opacity, 0.5, info = "check opacity argument")

  expect_error(opts_tooltip(use_fill = NULL), info = "check use_fill argument")
  opts <- settings_with(opts_tooltip(use_fill = FALSE))$tooltip
  expect_equal(opts$use_fill, FALSE, info = "check use_fill argument")

  expect_error(opts_tooltip(use_stroke = NA), info = "check use_stroke argument")
  opts <- settings_with(opts_tooltip(use_stroke = FALSE))$tooltip
  expect_equal(opts$use_stroke, FALSE, info = "check use_stroke argument")

  expect_error(opts_tooltip(delay_mouseover = "200"), info = "check delay_mouseover argument")
  expect_error(opts_tooltip(delay_mouseover = -50), info = "check delay_mouseover argument")
  opts <- settings_with(opts_tooltip(delay_mouseover = 50))$tooltip
  expect_equal(opts$delay_over, 50, info = "check delay_mouseover argument")

  expect_error(opts_tooltip(delay_mouseout = "200"), info = "check delay_mouseout argument")
  expect_error(opts_tooltip(delay_mouseout = -50), info = "check delay_mouseout argument")
  opts <- settings_with(opts_tooltip(delay_mouseout = 50))$tooltip
  expect_equal(opts$delay_out, 50, info = "check delay_mouseout argument")

  opts <- settings_with(opts_tooltip(placement = "auto"))$tooltip
  expect_equal(opts$placement, "doc", info = "check placement argument")
  options(xaringan.page_number.offset = 0)
  opts <- settings_with(opts_tooltip(placement = "auto"))$tooltip
  expect_equal(opts$placement, "container", info = "check placement in xarringan")
  options(xaringan.page_number.offset = NULL)
  expect_error(opts_tooltip(placement = "foo"), info = "check placement argument")

  expect_error(opts_tooltip(zindex = "200"), info = "check zindex argument")
  expect_error(opts_tooltip(zindex = 0), info = "check zindex argument")
  opts <- settings_with(opts_tooltip(zindex = 50.4))$tooltip
  expect_true(grepl("z-index:50", opts$css), info = "check zindex argument")
})

# opts_hover ----
test_that("opts_hover", {
  opts <- settings_with(opts_hover())$hover
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover is non-empty list")

  expect_error(opts_hover(reactive = NA), info = "check reactive argument")
  opts <- settings_with(opts_hover(reactive = FALSE))$hover
  expect_equal(opts$reactive, FALSE, info = "check reactive argument")

  expect_error(opts_hover(nearest_distance = "200"), info = "check nearest_distance argument")
  expect_error(opts_hover(nearest_distance = -50), info = "check nearest_distance argument")
  opts <- settings_with(opts_hover(nearest_distance = 50))$hover
  expect_equal(opts$nearest_distance, 50, info = "check nearest_distance argument")
})
# opts_hover_inv ----
test_that("opts_hover_inv", {
  opts <- settings_with(opts_hover_inv())$hover_inv
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover_inv is non-empty list")
})
# opts_hover_key ----
test_that("opts_hover_key", {
  opts <- settings_with(opts_hover_key())$hover_key
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover_key is non-empty list")

  expect_error(opts_hover_key(reactive = NA), info = "check reactive argument")
  opts <- settings_with(opts_hover_key(reactive = FALSE))$hover_key
  expect_equal(opts$reactive, FALSE, info = "check reactive argument")
})
# opts_hover_theme ----
test_that("opts_hover_theme", {
  opts <- settings_with(opts_hover_theme())$hover_theme
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_hover_theme is non-empty list")

  expect_error(opts_hover_theme(reactive = NA), info = "check reactive argument")
  opts <- settings_with(opts_hover_theme(reactive = FALSE))$hover_theme
  expect_equal(opts$reactive, FALSE, info = "check reactive argument")
})

# opts_selection ----
test_that("opts_selection", {
  opts <- settings_with(opts_selection())$select
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection is non-empty list")

  expect_error(opts_selection(type = "mixed"), info = "check type argument")
  opts <- settings_with(opts_selection(type = "single"))$select
  expect_equal(opts$type, "single", info = "check type argument")

  expect_error(opts_selection(only_shiny = NA), info = "check only_shiny argument")
  opts <- settings_with(opts_selection(only_shiny = FALSE))$select
  expect_equal(opts$only_shiny, FALSE, info = "check only_shiny argument")

  opts <- settings_with(opts_selection(selected = 1))$select
  expect_equal(opts$selected, "1", info = "check selected argument")
})
# opts_selection_inv ----
test_that("opts_selection_inv", {
  opts <- settings_with(opts_selection_inv())$select_inv
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection_inv is non-empty list")
})
# opts_selection_key ----
test_that("opts_selection_key", {
  opts <- settings_with(opts_selection_key())$select_key
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection_key is non-empty list")

  expect_error(opts_selection_key(type = "mixed"), info = "check type argument")
  opts <- settings_with(opts_selection_key(type = "single"))$select_key
  expect_equal(opts$type, "single", info = "check type argument")

  expect_error(opts_selection_key(only_shiny = NA), info = "check only_shiny argument")
  opts <- settings_with(opts_selection_key(only_shiny = FALSE))$select_key
  expect_equal(opts$only_shiny, FALSE, info = "check only_shiny argument")

  opts <- settings_with(opts_selection_key(selected = 1))$select_key
  expect_equal(opts$selected, "1", info = "check selected argument")
})
# opts_selection_theme ----
test_that("opts_selection_theme", {
  opts <- settings_with(opts_selection_theme())$select_theme
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_selection_theme is non-empty list")

  expect_error(opts_selection_theme(type = "mixed"), info = "check type argument")
  opts <- settings_with(opts_selection_theme(type = "single"))$select_theme
  expect_equal(opts$type, "single", info = "check type argument")

  expect_error(opts_selection_theme(only_shiny = NA), info = "check only_shiny argument")
  opts <- settings_with(opts_selection_theme(only_shiny = FALSE))$select_theme
  expect_equal(opts$only_shiny, FALSE, info = "check only_shiny argument")

  opts <- settings_with(opts_selection_theme(selected = 1))$select_theme
  expect_equal(opts$selected, "1", info = "check selected argument")
})

# opts_zoom ----
test_that("opts_zoom", {
  opts <- settings_with(opts_zoom())$zoom
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_zoom is non-empty list")

  expect_error(opts_zoom(min = "low"), info = "check min argument")
  expect_error(opts_zoom(min = 0.01), info = "check min argument")
  opts <- settings_with(opts_zoom(min = 1))$zoom
  expect_equal(opts$min, 1, info = "check min argument")

  expect_error(opts_zoom(max = "high"), info = "check max argument")
  expect_error(opts_zoom(max = 0.01), info = "check max argument")
  opts <- settings_with(opts_zoom(max = 1))$zoom
  expect_equal(opts$max, 1, info = "check max argument")

  expect_error(opts_zoom(min = 0.5, max = 0.4), info = "max > min")
  # 0.2 is the lower bound, accepted (it was refused)
  expect_equal(settings_with(opts_zoom(min = 0.2, max = 0.2))$zoom$min, 0.2)

  expect_error(opts_zoom(duration = "200"), info = "check duration argument")
  expect_error(opts_zoom(duration = -50), info = "check duration argument")
  opts <- settings_with(opts_zoom(duration = 50))$zoom
  expect_equal(opts$duration, 50, info = "check duration argument")
})

# opts_toolbar ----
test_that("opts_toolbar", {
  opts <- settings_with(opts_toolbar())$toolbar
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_toolbar is non-empty list")

  expect_error(opts_toolbar(position = "low"), info = "check position argument")
  opts <- settings_with(opts_toolbar(position = "top"))$toolbar
  expect_equal(opts$position, "top", info = "check position argument")

  expect_error(opts_toolbar(pngname = NULL), info = "check pngname argument")
  opts <- settings_with(opts_toolbar(pngname = "foo"))$toolbar
  expect_equal(opts$pngname, "foo", info = "check pngname argument")

  expect_error(opts_toolbar(tooltips = "b"), info = "check tooltips argument")
  expect_error(opts_toolbar(tooltips = list("b")), info = "check tooltips argument")
  opts <- settings_with(opts_toolbar(tooltips = list("a"="b")))$toolbar
  expect_equal(opts$tooltips, list("a"="b"), info = "check tooltips argument")

  expect_error(opts_toolbar(saveaspng = NA), info = "check saveaspng argument")
  expect_error(opts_toolbar(hidden = TRUE), info = "check hidden argument")
  opts <- settings_with(opts_toolbar(hidden = "selection"))$toolbar
  expect_equal(opts$hidden, "selection", info = "check hidden argument")
  opts <- settings_with(opts_toolbar(saveaspng = FALSE))$toolbar
  expect_equal(opts$hidden, "saveaspng", info = "check saveaspng/hidden argument")

  expect_error(opts_toolbar(delay_mouseover = "200"), info = "check delay_mouseover argument")
  expect_error(opts_toolbar(delay_mouseover = -50), info = "check delay_mouseover argument")
  opts <- settings_with(opts_toolbar(delay_mouseover = 50))$toolbar
  expect_equal(opts$delay_over, 50, info = "check delay_mouseover argument")

  expect_error(opts_toolbar(delay_mouseout = "200"), info = "check delay_mouseout argument")
  expect_error(opts_toolbar(delay_mouseout = -50), info = "check delay_mouseout argument")
  opts <- settings_with(opts_toolbar(delay_mouseout = 50))$toolbar
  expect_equal(opts$delay_out, 50, info = "check delay_mouseout argument")
})

# opts_toolbar colors ----
test_that("opts_toolbar colors", {
  color_args <- c("bg_color", "icon_color", "icon_active_color", "icon_hover_color")

  opts <- opts_toolbar()
  for (arg in color_args) {
    expect_null(opts[[arg]], info = paste(arg, "defaults to NULL"))
    expect_error(do.call(opts_toolbar, setNames(list(1), arg)), info = paste("check", arg))
    expect_error(do.call(opts_toolbar, setNames(list(c("red", "blue")), arg)), info = paste("check", arg))
    expect_error(do.call(opts_toolbar, setNames(list(" "), arg)), info = paste("check", arg))
  }

  opts <- opts_toolbar(
    bg_color = "#222222",
    icon_color = "white",
    icon_active_color = "rgba(255, 176, 0, 1)",
    icon_hover_color = "#fff"
  )
  expect_equal(opts$bg_color, "#222222")
  expect_equal(opts$icon_color, "white")
  expect_equal(opts$icon_active_color, "rgba(255, 176, 0, 1)")
  expect_equal(opts$icon_hover_color, "#fff")

  # the colors reach the widget settings and merge with other toolbar options
  library(ggplot2)
  g <- girafe(
    ggobj = ggplot(),
    options = list(
      opts_toolbar(position = "top"),
      opts_toolbar(icon_color = "white")
    )
  )
  expect_equal(g$x$settings$toolbar$position, "top")
  expect_equal(g$x$settings$toolbar$icon_color, "white")
  expect_null(g$x$settings$toolbar$bg_color)
})

# opts_sizing ----
test_that("opts_sizing", {
  opts <- settings_with(opts_sizing())$sizing
  expect_true(is.list(opts) && length(opts) > 0, info = "opts_sizing is non-empty list")
  expect_error(opts_sizing(rescale = "rescale"), info = "check rescale argument")
  expect_error(opts_sizing(width = "width"), info = "check width argument")
  expect_error(opts_sizing(width = -4), info = "check width range")
})

# options are merged argument by argument ----
test_that("options are merged argument by argument", {
  s <- settings_with(
    opts_tooltip(offx = 50),
    opts_tooltip(offy = 20),
    opts_zoom(max = 2),
    opts_toolbar(position = "bottom", pngname = "plot"),
    opts_sizing(rescale = FALSE)
  )
  expect_equal(s$tooltip$offx, 50)
  expect_equal(s$tooltip$offy, 20)
  expect_equal(s$zoom$max, 2)
  expect_equal(s$zoom$min, 1)
  expect_equal(s$toolbar$position, "bottom")
  expect_equal(s$toolbar$pngname, "plot")
  expect_false(s$sizing$rescale)
  expect_equal(s$sizing$width, 1)
})

# opts_*() objects keep only the arguments given ----
test_that("opts_*() objects keep only the arguments given", {
  expect_length(opts_tooltip(), 0)
  expect_equal(unclass(opts_tooltip(offx = 5, zindex = 42)), list(offx = 5, zindex = 42))
  expect_output(print(opts_zoom(max = 3)), "opts_zoom")
  expect_output(print(opts_zoom()), "No option set")
})

# zindex and saveaspng are combined with the other options ----
test_that("zindex and saveaspng are combined with the other options", {
  s <- settings_with(
    opts_tooltip(css = "background:navy;"),
    opts_tooltip(zindex = 42)
  )
  expect_match(s$tooltip$css, "background:navy;", fixed = TRUE)
  expect_match(s$tooltip$css, "z-index:42;", fixed = TRUE)

  s <- settings_with(
    opts_toolbar(hidden = "zoom_rect"),
    opts_toolbar(saveaspng = FALSE)
  )
  expect_setequal(s$toolbar$hidden, c("zoom_rect", "saveaspng"))
  s <- settings_with(opts_toolbar(saveaspng = FALSE), opts_toolbar(saveaspng = TRUE))
  expect_false("saveaspng" %in% s$toolbar$hidden)
})

# zoom bounds are compared after the merge ----
test_that("zoom bounds are compared after the merge", {
  expect_no_error(opts_zoom(max = 0.5))
  expect_error(settings_with(opts_zoom(max = 0.5)), "must be larger than or equal to `min`")
  expect_equal(settings_with(opts_zoom(min = 0.5), opts_zoom(max = 0.5))$zoom$max, 0.5)
})

# default_sizing_policy ----
test_that("default_sizing_policy", {
  opts <- ggiraph:::default_sizing_policy()
  expect_true(is.list(opts) && length(opts) > 0, info = "default_sizing_policy is non-empty list")
})

# merge_sizing_policy ----
test_that("merge_sizing_policy", {
  policy <- ggiraph:::default_sizing_policy()
  new_policy <- htmlwidgets::sizingPolicy(defaultWidth = 500, defaultHeight = 500)
  policy <- ggiraph:::merge_sizing_policy(policy, list(new_policy))
  expect_true(is.list(policy) && length(policy) > 0, info = "merge_sizing_policy is non-empty list")
  expect_identical(policy, new_policy, info = "merge_sizing_policy works")
})

# girafe_options ----
test_that("girafe_options", {
  expect_error(girafe_options("foo"), info = "check x argument")
  g <- girafe(code = {
    NULL
  })
  expect_identical(girafe_options(g), g, info = "no options set")
  result <- girafe_options(g, opts_zoom(1, 5))
  expect_equal(
    result$x$settings$zoom,
    list(min = 1, max = 5, duration = 300, default_on = FALSE),
    info = "zoom options set"
  )
  # the options given to girafe() are kept
  g <- girafe(ggobj = ggplot2::ggplot(), options = list(opts_zoom(max = 4)))
  result <- girafe_options(g, opts_tooltip(offx = 30))
  expect_equal(result$x$settings$zoom$max, 4)
  expect_equal(result$x$settings$tooltip$offx, 30)
  policy <- htmlwidgets::sizingPolicy(defaultWidth = 500, defaultHeight = 500)
  result <- girafe_options(g, policy)
  expect_identical(result$sizingPolicy, policy, info = "sizingPolicy set")
  expect_error(opts_hover(nearest_distance = "50"), info = "nearest_distance")
  expect_error(opts_hover(nearest_distance = -15), info = "nearest_distance")
})
