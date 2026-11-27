#' @title Tooltip settings
#' @description Settings to be used with [girafe()]
#' for tooltip customisation.
#' @param css extra css (added to \code{position: absolute;pointer-events: none;})
#' used to customize tooltip area.
#' @param use_cursor_pos should the cursor position be used to
#' position tooltip (in addition to offx and offy). Setting to
#' TRUE will have no effect in the RStudio browser windows.
#' @param opacity tooltip background opacity
#' @param delay_mouseover The duration in milliseconds of the
#' transition associated with tooltip display.
#' @param delay_mouseout The duration in milliseconds of the
#' transition associated with tooltip end of display.
#' @param offx,offy tooltip x and y offset
#' @param use_fill,use_stroke logical, use fill and stroke properties to
#' color tooltip.
#' @param placement Defines the container used for the tooltip element.
#' It can be one of "auto" (default), "doc" or "container".
#' \itemize{
#'   \item doc: the host document's body is used as tooltip container.
#'   The tooltip may cover areas outside of the svg graphic.
#'   \item container: the svg container is used as tooltip container.
#'   In this case the tooltip content may wrap to fit inside the svg bounds.
#'   It will also inherit the CSS styles and transforms applied to the parent containers
#'   (like scaling in a slide presentation).
#'   \item auto: This is the default, ggiraph choses the best option according
#'   to use cases. Usually it redirects to "doc", however in a *xaringan* context,
#'   it redirects to "container".
#' }
#' @param zindex tooltip css z-index, default to 9999.
#' @examples
#' library(ggplot2)
#'
#' dataset <- mtcars
#' dataset$carname = row.names(mtcars)
#'
#' gg <- ggplot(
#'   data = dataset,
#'   mapping = aes(x = wt, y = qsec, color = disp,
#'                 tooltip = carname, data_id = carname) ) +
#'   geom_point_interactive() + theme_minimal()
#'
#' x <- girafe(ggobj = gg)
#' x <- girafe_options(x,
#'   opts_tooltip(opacity = .7,
#'     offx = 20, offy = -10,
#'     use_fill = TRUE, use_stroke = TRUE,
#'     delay_mouseout = 1000) )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
opts_tooltip <- function(
  css = NULL,
  offx = 10,
  offy = 0,
  use_cursor_pos = TRUE,
  opacity = .9,
  use_fill = FALSE,
  use_stroke = FALSE,
  delay_mouseover = 200,
  delay_mouseout = 500,
  placement = c("auto", "doc", "container"),
  zindex = 9999
) {
  check_css(css, default = "", cls_prefix = "tooltip_", lines = FALSE)
  if (!is.null(css) && grepl(x = css, pattern = "position[ ]*:")) {
    cli::cli_abort(
      "Do not specify {.code position} in {.arg css}, it is managed by girafe."
    )
  }
  if (!is.null(css) && grepl(x = css, pattern = "pointer-events[ ]*:")) {
    cli::cli_abort(
      "Do not specify {.code pointer-events} in {.arg css}, it is managed by girafe."
    )
  }

  check_number_decimal(zindex, min = 1)
  check_number_decimal(offx)
  check_number_decimal(offy)
  check_bool(use_cursor_pos)
  check_number_positive(opacity, max = 1)
  check_bool(use_fill)
  check_bool(use_stroke)
  check_number_decimal(delay_mouseover, min = 0)
  check_number_decimal(delay_mouseout, min = 0)
  placement <- arg_match(placement)
  new_opts("opts_tooltip", match.call(), environment())
}

#' @title Hover effect settings
#' @description Allows customization of the rendering
#' of graphic elements when the user hovers over them with the cursor (mouse pointer).
#' Use `opts_hover` for interactive geometries in panels,
#' `opts_hover_key` for interactive scales/guides and
#' `opts_hover_theme` for interactive theme elements.
#' Use `opts_hover_inv` for the effect on the rest of the geometries,
#' while one is hovered (inverted operation).
#' @param css css to associate with elements when they are hovered.
#' It must be a scalar character. It can also be constructed with
#' [girafe_css()], to give more control over the css for different element types.
#' @param reactive if TRUE, in Shiny context, hovering will set Shiny input values.
#' @param nearest_distance a scalar positive number defining the maximum distance to use
#' when using the `hover_nearest` [interactive parameter][interactive_parameters] feature.
#' By default (`NULL`) it's set to `Infinity` which means that there is no distance limit.
#' Setting it to 50, for example, it will hover the nearest element that has
#' at maximum 50 SVG units (pixels) distance from the mouse cursor.
#' @param linked if TRUE, hovering a legend/guide element (`key-id`) will
#' also highlight the corresponding geometry elements (`data-id`) and vice versa.
#' @note **IMPORTANT**: When applying a `fill` style with the `css` argument,
#' be aware that the browser's CSS engine will apply it also to line elements,
#' if there are any that use the hovering feature. This will cause an undesired effect.
#'
#' To overcome this, supply the argument `css` using [girafe_css()],
#' in order to set the `fill` style only for the desired elements.
#' @examples
#' library(ggplot2)
#'
#' dataset <- mtcars
#' dataset$carname = row.names(mtcars)
#'
#' gg <- ggplot(
#'   data = dataset,
#'   mapping = aes(x = wt, y = qsec, color = disp,
#'                 tooltip = carname, data_id = carname) ) +
#'   geom_point_interactive() + theme_minimal()
#'
#' x <- girafe(ggobj = gg)
#' x <- girafe_options(x,
#'   opts_hover(css = "fill:wheat;stroke:orange;r:5pt;") )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
#' @seealso [girafe_css()], [girafe_css_bicolor()]
opts_hover <- function(css = NULL, reactive = FALSE, nearest_distance = NULL, linked = FALSE) {
  check_css(css, default = "", cls_prefix = "hover_data_")
  check_bool(reactive)
  check_number_decimal(nearest_distance, min = 0, allow_null = TRUE)
  check_bool(linked)
  new_opts("opts_hover", match.call(), environment())
}

#' @export
#' @rdname opts_hover
opts_hover_inv <- function(css = NULL) {
  check_css(css, default = "", cls_prefix = "hover_inv_")
  new_opts("opts_hover_inv", match.call(), environment())
}

#' @export
#' @rdname opts_hover
opts_hover_key <- function(css = NULL, reactive = FALSE) {
  check_css(css, default = "", cls_prefix = "hover_key_")
  check_bool(reactive)
  new_opts("opts_hover_key", match.call(), environment())
}

#' @export
#' @rdname opts_hover
opts_hover_theme <- function(css = NULL, reactive = FALSE) {
  check_css(css, default = "", cls_prefix = "hover_theme_")
  check_bool(reactive)
  new_opts("opts_hover_theme", match.call(), environment())
}

#' @title Selection effect settings
#' @description Allows customization of the rendering of
#' selected graphic elements.
#' Use `opts_selection` for interactive geometries in panels,
#' `opts_selection_key` for interactive scales/guides and
#' `opts_selection_theme` for interactive theme elements.
#' Use `opts_selection_inv` for the effect on the rest of the geometries,
#' while some are selected (inverted operation).
#' @param css css to associate with elements when they are selected.
#' It must be a scalar character. It can also be constructed with
#' [girafe_css()], to give more control over the css for different element types.
#' @param type selection mode ("single", "multiple", "none")
#'  when widget is in a Shiny application.
#' @param only_shiny disable selections when not running within a Shiny
#' application. Defaults to `TRUE` because selection is primarily
#' designed for Shiny interactivity, where selected elements can be
#' captured as reactive values. Set to `FALSE` only to demonstrate
#' the selection/lasso feature in standalone HTML pages (e.g. in
#' documentation examples or R Markdown output).
#' @param selected character vector, id to be selected when the graph will be
#' initialized.
#' @param linked if TRUE, selecting a legend/guide element (`key-id`) will
#' also select the corresponding geometry elements (`data-id`) and vice versa.
#' @note **IMPORTANT**: When applying a `fill` style with the `css` argument,
#' be aware that the browser's CSS engine will apply it also to line elements,
#' if there are any that use the selection feature. This will cause an undesired effect.
#'
#' To overcome this, supply the argument `css` using [girafe_css()],
#' in order to set the `fill` style only for the desired elements.
#' @examples
#' library(ggplot2)
#'
#' dataset <- mtcars
#' dataset$carname = row.names(mtcars)
#'
#' gg <- ggplot(
#'   data = dataset,
#'   mapping = aes(x = wt, y = qsec, color = disp,
#'                 tooltip = carname, data_id = carname) ) +
#'   geom_point_interactive() + theme_minimal()
#'
#' x <- girafe(ggobj = gg)
#' x <- girafe_options(x,
#'   opts_selection(type = "multiple", only_shiny = FALSE,
#'     css = "fill:red;stroke:gray;r:5pt;") )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
#' @seealso [girafe_css()], [girafe_css_bicolor()]
opts_selection <- function(
  css = NULL,
  type = c("multiple", "single", "none"),
  only_shiny = TRUE,
  selected = character(0),
  linked = FALSE
) {
  check_css(css, default = "", cls_prefix = "select_data_")
  type <- arg_match(type)
  check_bool(only_shiny)
  check_bool(linked)
  new_opts("opts_selection", match.call(), environment())
}

#' @export
#' @rdname opts_selection
opts_selection_inv <- function(css = NULL) {
  check_css(css, default = "", cls_prefix = "select_inv_")
  new_opts("opts_selection_inv", match.call(), environment())
}

#' @export
#' @rdname opts_selection
opts_selection_key <- function(
  css = NULL,
  type = c("single", "multiple", "none"),
  only_shiny = TRUE,
  selected = character(0)
) {
  check_css(css, default = "", cls_prefix = "select_key_")
  type <- arg_match(type)
  check_bool(only_shiny)
  new_opts("opts_selection_key", match.call(), environment())
}

#' @export
#' @rdname opts_selection
opts_selection_theme <- function(
  css = NULL,
  type = c("single", "multiple", "none"),
  only_shiny = TRUE,
  selected = character(0)
) {
  check_css(css, default = "", cls_prefix = "select_theme_")
  type <- arg_match(type)
  check_bool(only_shiny)
  new_opts("opts_selection_theme", match.call(), environment())
}

#' @title Zoom settings
#' @description Allows customization of the zoom.
#' @param min minimum zoom factor
#' @param max maximum zoom factor
#' @param duration duration of the zoom transitions, in milliseconds
#' @param default_on if TRUE, pan/zoom will be activated by default when the plot is rendered
#' @examples
#' library(ggplot2)
#'
#' dataset <- mtcars
#' dataset$carname = row.names(mtcars)
#'
#' gg <- ggplot(
#'   data = dataset,
#'   mapping = aes(x = wt, y = qsec, color = disp,
#'                 tooltip = carname, data_id = carname) ) +
#'   geom_point_interactive() + theme_minimal()
#'
#' x <- girafe(ggobj = gg)
#' x <- girafe_options(x,
#'   opts_zoom(min = .7, max = 2, default_on = TRUE) )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
opts_zoom <- function(min = 1, max = 1, duration = 300, default_on = FALSE) {
  check_number_decimal(min, min = 0.2)
  check_number_decimal(max, min = 0.2)
  # with only one of them, they are compared after the merge with the
  # defaults, when girafe() builds its settings
  if (!missing(min) && !missing(max)) {
    check_zoom_range(min, max)
  }
  check_number_decimal(duration, min = 0)
  check_bool(default_on)
  new_opts("opts_zoom", match.call(), environment())
}

check_zoom_range <- function(min, max, call = caller_env()) {
  if (max < min) {
    cli::cli_abort(
      "{.arg max} ({max}) must be larger than or equal to {.arg min} ({min}) in {.fn opts_zoom}.",
      call = call
    )
  }
}

#' @title Toolbar settings
#' @description Allows customization of the toolbar
#'
#' @param position Position of the toolbar relative to the plot.
#' One of 'top', 'bottom', 'topleft', 'topright', 'bottomleft', 'bottomright'
#' @param saveaspng Show (TRUE) or hide (FALSE) the 'download png' button.
#' @param pngname The default basename (without .png extension) to use for the png file.
#' @param delay_mouseover The duration in milliseconds of the
#' transition associated with toolbar display.
#' @param delay_mouseout The duration in milliseconds of the
#' transition associated with toolbar end of display.
#' @param tooltips A named list with tooltip labels for the buttons,
#' for adapting to other language. Passing NULL will use the default tooltips:
#'
#' list(
#'   lasso_select = 'lasso selection',
#'   lasso_deselect = 'lasso deselection',
#'   zoom_on = 'activate pan/zoom',
#'   zoom_off = 'deactivate pan/zoom',
#'   zoom_rect = 'zoom with rectangle',
#'   zoom_reset = 'reset pan/zoom',
#'   saveaspng = 'download png',
#'   fullscreen = 'fullscreen'
#' )
#' @param fixed if FALSE (default), the toolbar will float above the graphic, if
#' TRUE, the toolbar will be fixed and always visible.
#' @param hidden A character vector with the names of the buttons or button groups to be hidden
#' from the toolbar. This allows full customization of which buttons appear.
#'
#' Valid button groups: 'selection', 'zoom', 'misc'
#'
#' Valid button names: 'lasso_select', 'lasso_deselect', 'zoom_onoff', 'zoom_rect', 'zoom_reset', 'saveaspng', 'fullscreen'
#' @param bg_color,icon_color,icon_active_color,icon_hover_color Colors
#' of the toolbar, as CSS color values (e.g. `"#333333"`, `"white"` or
#' `"rgba(0, 0, 0, 0.5)"`): the background of the toolbar, the color of the
#' icons, the color of the icons of active buttons (zoom activated, lasso
#' deselection) and the color of the hovered icon. If `NULL` (default),
#' the default colors are used.
#'
#' @section Toolbar colors:
#' The toolbar colors are defined by CSS variables, which `bg_color`,
#' `icon_color`, `icon_active_color` and `icon_hover_color` set for one
#' graphic. To set them for all the graphics of a document or of an
#' application, define these variables in a stylesheet:
#'
#' ```css
#' .ggiraph-toolbar {
#'   --ggiraph-toolbar-bg: #222222;
#'   --ggiraph-toolbar-icon-color: #f0f0f0;
#'   --ggiraph-toolbar-icon-active-color: #ffb000;
#'   --ggiraph-toolbar-icon-hover-color: #ffffff;
#' }
#' ```
#'
#' In R Markdown or Quarto, this rule can be written in a `css` chunk;
#' prefix the selector with a class (e.g. `.my-class .ggiraph-toolbar`)
#' to apply it only to the graphics inside an element of that class.
#'
#' @note
#' `saveaspng` relies on JavaScript promises, so any browsers that don't natively
#' support the standard Promise object will need to have a polyfill (e.g.
#' Internet Explorer with version less than 11 will need it).
#' @examples
#' library(ggiraph)
#' library(ggplot2)
#'
#' dataset <- mtcars
#' dataset$carname <- row.names(mtcars)
#'
#' gg <- ggplot(
#'   data = dataset,
#'   mapping = aes(
#'     x = wt, y = qsec, color = disp,
#'     tooltip = carname, data_id = carname
#'   )
#' ) +
#'   geom_point_interactive() +
#'   theme_minimal()
#'
#' x <- girafe(
#'   ggobj = gg,
#'   options = list(
#'     opts_zoom(max = 5),
#'     opts_selection(only_shiny = FALSE),
#'     opts_toolbar(position = "top")
#'   )
#' )
#' if (interactive()) print(x)
#'
#' # Hide lasso selection tools (useful in Shiny when selections
#' # are controlled by other app interactions)
#' x <- girafe(
#'   ggobj = gg,
#'   options = list(
#'     opts_zoom(max = 5),
#'     opts_selection(only_shiny = FALSE),
#'     opts_toolbar(
#'       position = "top",
#'       hidden = c("lasso_select", "lasso_deselect")
#'     )
#'   )
#' )
#' if (interactive()) print(x)
#'
#'
#' # Keep only zoom/pan and reset, hide rectangular zoom
#' x <- girafe(
#'   ggobj = gg,
#'   options = list(
#'     opts_zoom(max = 5),
#'     opts_selection(only_shiny = FALSE),
#'     opts_toolbar(
#'       position = "top",
#'       hidden = c("selection", "zoom_rect", "saveaspng")
#'     )
#'   )
#' )
#' if (interactive()) print(x)
#'
#' # Change the toolbar colors
#' x <- girafe(
#'   ggobj = gg,
#'   options = list(
#'     opts_zoom(max = 5),
#'     opts_toolbar(
#'       fixed = TRUE,
#'       bg_color = "#222222",
#'       icon_color = "#f0f0f0",
#'       icon_active_color = "#ffb000",
#'       icon_hover_color = "white"
#'     )
#'   )
#' )
#' if (interactive()) print(x)
#' @export
#' @family girafe animation options
opts_toolbar <- function(
  position = c(
    "topright",
    "top",
    "bottom",
    "topleft",
    "bottomleft",
    "bottomright"
  ),
  saveaspng = TRUE,
  pngname = "diagram",
  tooltips = NULL,
  hidden = NULL,
  fixed = FALSE,
  delay_mouseover = 200,
  delay_mouseout = 500,
  bg_color = NULL,
  icon_color = NULL,
  icon_active_color = NULL,
  icon_hover_color = NULL
) {
  position <- arg_match(position)
  check_bool(saveaspng)
  check_string(pngname, allow_empty = FALSE)
  check_not_blank(pngname)
  if (!is.null(tooltips) && !(is.list(tooltips) && is_named(tooltips))) {
    cli::cli_abort("{.arg tooltips} must be a named list or {.code NULL}.")
  }
  if (!is.null(hidden) && !is.character(hidden)) {
    cli::cli_abort("{.arg hidden} must be a character vector.")
  }
  check_number_decimal(delay_mouseover, min = 0)
  check_number_decimal(delay_mouseout, min = 0)
  colors <- list(
    bg_color = bg_color,
    icon_color = icon_color,
    icon_active_color = icon_active_color,
    icon_hover_color = icon_hover_color
  )
  for (arg in names(colors)) {
    value <- colors[[arg]]
    check_string(value, allow_empty = FALSE, allow_null = TRUE, arg = arg)
    check_not_blank(value, arg = arg)
  }
  new_opts("opts_toolbar", match.call(), environment())
}


#' @title Girafe sizing settings
#' @description Allows customization of the svg style sizing
#' @param rescale If FALSE, graphic will not be resized and the dimensions are exactly
#' those of the svg. If TRUE the graphic will be resize to fit its container
#' @param width widget width ratio (0 < width <= 1).
#' @family girafe animation options
#' @examples
#' library(ggplot2)
#'
#' dataset <- mtcars
#' dataset$carname = row.names(mtcars)
#'
#' gg <- ggplot(
#'   data = dataset,
#'   mapping = aes(x = wt, y = qsec, color = disp,
#'                 tooltip = carname, data_id = carname) ) +
#'   geom_point_interactive() + theme_minimal()
#'
#' x <- girafe(ggobj = gg)
#' x <- girafe_options(x,
#'   opts_sizing(rescale = FALSE) )
#' if( interactive() ) print(x)
#' @export
opts_sizing <- function(rescale = TRUE, width = 1) {
  check_bool(rescale)
  check_number_positive(width, max = 1)
  new_opts("opts_sizing", match.call(), environment())
}

#' @title Set girafe options
#' @description Defines the animation options related to
#' a [girafe()] object.
#' @param x girafe object.
#' @param ... set of options defined by calls to \code{opts_*} functions or
#' to sizingPolicy from htmlwidgets (this won't have any effect within a
#' shiny context).
#' @examples
#' library(ggplot2)
#' library(htmlwidgets)
#'
#' dataset <- mtcars
#' dataset$carname = row.names(mtcars)
#'
#' gg_point = ggplot( data = dataset,
#'     mapping = aes(x = wt, y = qsec, color = disp,
#'     tooltip = carname, data_id = carname) ) +
#'   geom_point_interactive() + theme_minimal()
#'
#' x <- girafe(ggobj = gg_point)
#' x <- girafe_options(x = x,
#'     opts_tooltip(opacity = .7),
#'     opts_zoom(min = .5, max = 4),
#'     sizingPolicy(defaultWidth = "100%", defaultHeight = "300px"),
#'     opts_hover(css = "fill:red;stroke:orange;r:5pt;") )
#'
#' if(interactive()){
#'   print(x)
#' }
#' @export
#' @seealso [girafe()], [girafe_css()], [girafe_css_bicolor()]
#' @importFrom rlang list2
#' @family girafe animation options
girafe_options <- function(x, ...) {
  if (!inherits(x, "girafe")) {
    cli::cli_abort("{.arg x} must be a {.cls girafe} object, not {.obj_type_friendly {x}}.")
  }

  args <- list2(...)
  # the options asked for, kept by girafe(), are merged and computed again
  opts <- merge_opts(x$girafe_opts %||% girafe_defaults(), args)
  x$x$settings <- opts_settings(opts)
  x$girafe_opts <- opts
  x$sizingPolicy <- merge_sizing_policy(x$sizingPolicy, args)
  x
}

# Options ----
#
# An `opts_*()` object keeps only the arguments given by the user, under
# their own names, validated but not computed. Options are merged with
# modifyList(): the last given wins, argument by argument. The settings
# sent to the JavaScript code are computed once, after the merge, by
# opts_settings(). The defaults are complete objects (every argument), so
# that the result of set_girafe_defaults() can be given back to it.

new_opts <- function(class, call, env) {
  args <- as.character(names(call)[-1])
  x <- mget(args, envir = env)
  structure(x, class = c(class, "girafe_opts"))
}

# the names of the settings read by the JavaScript code
opts_settings_names <- c(
  opts_tooltip = "tooltip",
  opts_hover = "hover",
  opts_hover_inv = "hover_inv",
  opts_hover_key = "hover_key",
  opts_hover_theme = "hover_theme",
  opts_selection = "select",
  opts_selection_inv = "select_inv",
  opts_selection_key = "select_key",
  opts_selection_theme = "select_theme",
  opts_zoom = "zoom",
  opts_toolbar = "toolbar",
  opts_sizing = "sizing"
)

# every argument of an opts_*() function, the missing ones with their
# default value (the first one for a choice)
complete_opts <- function(x) {
  cls <- class(x)[1]
  fun <- get(cls, mode = "function", envir = topenv())
  defaults <- lapply(formals(fun), function(value) {
    value <- eval(value, baseenv())
    if (is.character(value) && length(value) > 1) value[1] else value
  })
  structure(
    utils::modifyList(defaults, unclass(x), keep.null = TRUE),
    class = c(cls, "girafe_opts")
  )
}

merge_single_opts <- function(x, y) {
  structure(
    utils::modifyList(unclass(x), unclass(y), keep.null = TRUE),
    class = class(x)
  )
}

merge_opts <- function(opts, args) {
  for (arg in args) {
    cls <- class(arg)[1]
    if (cls %in% names(opts_settings_names)) {
      opts[[cls]] <- merge_single_opts(opts[[cls]], arg)
    }
  }
  opts
}

# the settings sent to the JavaScript code
opts_settings <- function(opts, call = caller_env()) {
  settings <- lapply(names(opts_settings_names), function(cls) {
    x <- opts[[cls]] %||% structure(list(), class = c(cls, "girafe_opts"))
    opts_setting(complete_opts(x), call = call)
  })
  names(settings) <- opts_settings_names
  settings
}

opts_setting <- function(x, call = caller_env()) {
  cls <- class(x)[1]
  x <- unclass(x)
  css <- function(default, prefix, lines = TRUE) {
    check_css(x$css, default = default, cls_prefix = prefix, lines = lines, call = call)
  }
  switch(
    cls,
    opts_tooltip = {
      tooltip_css <- trimws(sub(
        "\\}[\n]*$",
        paste0(
          "; position:absolute;pointer-events:none;",
          sprintf("z-index:%.0f;", round(x$zindex, digits = 0)),
          "}\n"
        ),
        css(
          "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;text-align:left;",
          "tooltip_",
          lines = FALSE
        )
      ))
      placement <- x$placement
      if (placement == "auto") {
        is_xaringan <- !is.null(getOption("xaringan.page_number.offset"))
        placement <- if (is_xaringan) "container" else "doc"
      }
      list(
        css = tooltip_css,
        placement = placement,
        opacity = x$opacity,
        offx = x$offx,
        offy = x$offy,
        use_cursor_pos = x$use_cursor_pos,
        use_fill = x$use_fill,
        use_stroke = x$use_stroke,
        delay_over = x$delay_mouseover,
        delay_out = x$delay_mouseout
      )
    },
    opts_hover = list(
      css = css("fill:orange;stroke:gray;", "hover_data_"),
      reactive = x$reactive,
      nearest_distance = x$nearest_distance,
      linked = x$linked
    ),
    opts_hover_inv = list(css = css("", "hover_inv_")),
    opts_hover_key = list(
      css = css("stroke:red;", "hover_key_"),
      reactive = x$reactive
    ),
    opts_hover_theme = list(
      css = css("fill:green;", "hover_theme_"),
      reactive = x$reactive
    ),
    opts_selection = list(
      css = css("fill:red;stroke:gray;", "select_data_"),
      type = x$type,
      only_shiny = x$only_shiny,
      selected = as.character(x$selected),
      linked = x$linked
    ),
    opts_selection_inv = list(css = css("", "select_inv_")),
    opts_selection_key = list(
      css = css("stroke:gray;", "select_key_"),
      type = x$type,
      only_shiny = x$only_shiny,
      selected = as.character(x$selected)
    ),
    opts_selection_theme = list(
      css = css("stroke:gray;", "select_theme_"),
      type = x$type,
      only_shiny = x$only_shiny,
      selected = as.character(x$selected)
    ),
    opts_zoom = {
      check_zoom_range(x$min, x$max, call = call)
      list(
        min = x$min,
        max = x$max,
        duration = x$duration,
        default_on = x$default_on
      )
    },
    opts_toolbar = {
      hidden <- x$hidden %||% character()
      if (isFALSE(x$saveaspng) && !"saveaspng" %in% hidden) {
        hidden <- c(hidden, "saveaspng")
      }
      list(
        position = x$position,
        pngname = x$pngname,
        tooltips = x$tooltips,
        fixed = x$fixed,
        hidden = hidden,
        delay_over = x$delay_mouseover,
        delay_out = x$delay_mouseout,
        bg_color = x$bg_color,
        icon_color = x$icon_color,
        icon_active_color = x$icon_active_color,
        icon_hover_color = x$icon_hover_color
      )
    },
    opts_sizing = list(rescale = x$rescale, width = x$width)
  )
}

#' @export
print.girafe_opts <- function(x, ...) {
  cat("<", class(x)[1], ">\n", sep = "")
  if (length(x) == 0) {
    cat("No option set.\n")
  } else {
    utils::str(unclass(x), no.list = TRUE, give.attr = FALSE)
  }
  invisible(x)
}

merge_sizing_policy <- function(policy, args) {
  for (arg in args) {
    # an opts_*() object without argument is an empty list, as a sizing
    # policy without argument
    if (
      is.list(arg) && !inherits(arg, "girafe_opts") &&
        all(names(arg) %in% names(htmlwidgets::sizingPolicy()))
    ) {
      policy <- arg
    }
  }
  policy
}

default_sizing_policy <- function() {
  sizingPolicy(knitr.figure = TRUE, browser.fill = FALSE)
}
