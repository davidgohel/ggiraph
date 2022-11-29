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
#' @param zindex tooltip css z-index, default to 999.
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
opts_tooltip <- function(css = NULL,
                         offx = 10,
                         offy = 0,
                         use_cursor_pos = TRUE,
                         opacity = .9,
                         use_fill = FALSE,
                         use_stroke = FALSE,
                         delay_mouseover = 200,
                         delay_mouseout = 500,
                         placement = c("auto", "doc", "container"),
                         zindex = 999) {
  css <- check_css(
    css = css,
    default = "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;text-align:left;",
    cls_prefix = "tooltip_",
    name = "opts_tooltip"
  )
  if( grepl(x = css, pattern = "position[ ]*:") )
    abort("do not specify position in css, this parameter is managed by girafe.")
  if( grepl(x = css, pattern = "pointer-events[ ]*:") )
    abort("do not specify pointer-events in css, this parameter is managed by girafe.")

  if (!is_valid_number(zindex) || zindex < 1) {
    abort("`zindex` must be a scalar positive number, >= 1", call = NULL)
  }
  zindex <- round(zindex, digits = 0)

  css <- trimws(sub(
    "\\}[\n]*$",
    paste0(
      "; position:absolute;pointer-events:none;",
      sprintf("z-index:%.0f;", zindex),
      "}\n"
    ),
    css
  ))

  if (!is_valid_number(offx)) {
    abort("`offx` must be a scalar number", call = NULL)
  }
  if (!is_valid_number(offy)) {
    abort("`offy` must be a scalar number", call = NULL)
  }
  if (!is_valid_logical(use_cursor_pos)) {
    abort("`use_cursor_pos` must be a scalar logical", call = NULL)
  }
  if (!is_valid_number(opacity) || opacity <= 0 || opacity > 1) {
    abort("`opacity` must be a scalar number, 0 < opacity <= 1", call = NULL)
  }
  if (!is_valid_logical(use_fill)) {
    abort("`use_fill` must be a scalar logical", call = NULL)
  }
  if (!is_valid_logical(use_stroke)) {
    abort("`use_stroke` must be a scalar logical", call = NULL)
  }
  if (!is_valid_number(delay_mouseover) || delay_mouseover < 0) {
    abort("`delay_mouseover` must be a scalar positive number", call = NULL)
  }
  if (!is_valid_number(delay_mouseout) || delay_mouseout < 0) {
    abort("`delay_mouseout` must be a scalar positive number", call = NULL)
  }
  placement = arg_match(placement, error_call = NULL)
  if (placement == "auto") {
    placement <- "doc"
    is_xaringan <- !is.null(getOption("xaringan.page_number.offset"))
    if (is_xaringan) {
      placement <- "container"
    }
  }

  x <- list(
    css = css,
    placement = placement,
    opacity = opacity,
    offx = offx, offy = offy,
    use_cursor_pos = use_cursor_pos,
    use_fill = use_fill,
    use_stroke = use_stroke,
    delay_over = delay_mouseover,
    delay_out = delay_mouseout
  )
  class(x) <- "opts_tooltip"
  x
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
opts_hover <- function(css = NULL,
                       reactive = FALSE,
                       nearest_distance = NULL) {
  css <- check_css(css,
                   default = "fill:orange;stroke:gray;",
                   cls_prefix = "hover_data_",
                   name = "opts_hover")
  if (!is_valid_logical(reactive)) {
    abort("`reactive` must be a scalar logical", call = NULL)
  }
  if (!is.null(nearest_distance) && !(is_valid_number(nearest_distance) && nearest_distance >= 0)) {
    abort("`nearest_distance` must be a scalar positive number or NULL", call. = FALSE)
  }

  structure(list(css = css, reactive = reactive, nearest_distance = nearest_distance),
            class = "opts_hover")
}

#' @export
#' @rdname opts_hover
opts_hover_inv <- function(css = NULL) {
  css <- check_css(css,
                   default = "",
                   cls_prefix = "hover_inv_",
                   name = "opts_hover_inv")
  structure(list(css = css),
            class = "opts_hover_inv")
}

#' @export
#' @rdname opts_hover
opts_hover_key <- function(css = NULL,
                           reactive = FALSE) {
  css <- check_css(css,
                   default = "stroke:red;",
                   cls_prefix = "hover_key_",
                   name = "opts_hover")
  if (!is_valid_logical(reactive)) {
    abort("`reactive` must be a scalar logical", call = NULL)
  }

  structure(list(css = css, reactive = reactive),
            class = "opts_hover_key")
}

#' @export
#' @rdname opts_hover
opts_hover_theme <- function(css = NULL,
                             reactive = FALSE) {
  css <- check_css(css,
                   default = "fill:green;",
                   cls_prefix = "hover_theme_",
                   name = "opts_hover_theme")
  if (!is_valid_logical(reactive)) {
    abort("`reactive` must be a scalar logical", call = NULL)
  }

  structure(list(css = css, reactive = reactive),
            class = "opts_hover_theme")
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
#' @param only_shiny disable selections if not in a shiny context.
#' @param selected character vector, id to be selected when the graph will be
#' initialized.
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
opts_selection <- function(css = NULL,
                           type = c("multiple", "single", "none"),
                           only_shiny = TRUE,
                           selected = character(0)) {
  css <- check_css(css,
                   default = "fill:red;stroke:gray;",
                   cls_prefix = "select_data_",
                   name = "opts_selection")
  type = arg_match(type, error_call = NULL)
  if (!is_valid_logical(only_shiny)) {
    abort("`only_shiny` must be a scalar logical", call = NULL)
  }

  structure(list(
    css = css,
    type = type,
    only_shiny = only_shiny,
    selected = as.character(selected)
  ),
  class = "opts_selection")
}

#' @export
#' @rdname opts_selection
opts_selection_inv <- function(css = NULL) {
  css <- check_css(css,
                   default = "",
                   cls_prefix = "select_inv_",
                   name = "opts_selection_inv")
  structure(list(css = css),
            class = "opts_selection_inv")
}

#' @export
#' @rdname opts_selection
opts_selection_key <- function(css = NULL,
                               type = c("single", "multiple", "none"),
                               only_shiny = TRUE,
                               selected = character(0)) {
  css <- check_css(css,
                   default = "stroke:gray;",
                   cls_prefix = "select_key_",
                   name = "opts_selection_key")
  type = arg_match(type, error_call = NULL)
  if (!is_valid_logical(only_shiny)) {
    abort("`only_shiny` must be a scalar logical", call = NULL)
  }

  structure(list(
    css = css,
    type = type,
    only_shiny = only_shiny,
    selected = as.character(selected)
  ),
  class = "opts_selection_key")
}

#' @export
#' @rdname opts_selection
opts_selection_theme <- function(css = NULL,
                                 type = c("single", "multiple", "none"),
                                 only_shiny = TRUE,
                                 selected = character(0)) {
  css <- check_css(css,
                   default = "stroke:gray;",
                   cls_prefix = "select_theme_",
                   name = "opts_selection_theme")
  type = arg_match(type, error_call = NULL)
  if (!is_valid_logical(only_shiny)) {
    abort("`only_shiny` must be a scalar logical", call = NULL)
  }

  structure(list(
    css = css,
    type = type,
    only_shiny = only_shiny,
    selected = as.character(selected)
  ),
  class = "opts_selection_theme")
}

#' @title Zoom settings
#' @description Allows customization of the zoom.
#' @param min minimum zoom factor
#' @param max maximum zoom factor
#' @param duration duration of the zoom transitions, in milliseconds
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
#'   opts_zoom(min = .7, max = 2) )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
opts_zoom <- function(min = 1, max = 1, duration = 300){
  if (!is_valid_number(min) || min <= 0.2) {
    abort("`min` must be a scalar number, >= 0.2", call = NULL)
  }
  if (!is_valid_number(max) || min <= 0.2) {
    abort("`max` must be a scalar number, >= 0.2", call = NULL)
  }
  if (max < min) {
    abort("`max` must be bigger than `min`", call = NULL)
  }
  if (!is_valid_number(duration) || duration < 0) {
    abort("`duration` must be a scalar positive number", call = NULL)
  }

  x <- list(
    min = min,
    max = max,
    duration = duration
  )
  class(x) <- "opts_zoom"
  x
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
#'   saveaspng = 'download png'
#' )
#'
#' @param hidden A character vector with the names of the buttons or button groups to be hidden
#' from the toolbar.
#'
#' Valid button groups: selection, zoom, misc
#'
#' Valid button names: lasso_select, lasso_deselect, zoom_onoff, zoom_rect, zoom_reset, saveaspng
#'
#' @note
#' `saveaspng` relies on JavaScript promises, so any browsers that don't natively
#' support the standard Promise object will need to have a polyfill (e.g.
#' Internet Explorer with version less than 11 will need it).
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
#'   opts_toolbar(position = "top") )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
opts_toolbar <- function(position = c("topright", "top", "bottom",
                                      "topleft",  "bottomleft", "bottomright"),
                         saveaspng = TRUE,
                         pngname = "diagram",
                         tooltips = NULL,
                         hidden = NULL,
                         delay_mouseover = 200,
                         delay_mouseout = 500) {
  position = arg_match(position, error_call = NULL)
  if (!is_valid_logical(saveaspng)) {
    abort("`saveaspng` must be a scalar logical", call = NULL)
  }
  if (!is_valid_string_non_empty(pngname)) {
    abort("`pngname` must be a non-empty scalar character", call = NULL)
  }
  if (!is.null(tooltips) && !(is.list(tooltips) && is_named(tooltips))) {
    abort("`tooltips` must be a named list or NULL", call = NULL)
  }
  if (is.null(hidden)) {
    hidden = character()
  }
  if (!is.character(hidden)) {
    abort("`hidden` must be a character vector", call = NULL)
  }
  if (isFALSE(saveaspng) && !"saveaspng" %in% hidden) {
    hidden = c(hidden, "saveaspng")
  }
  if (!is_valid_number(delay_mouseover) || delay_mouseover < 0) {
    abort("`delay_mouseover` must be a scalar positive number", call = NULL)
  }
  if (!is_valid_number(delay_mouseout) || delay_mouseout < 0) {
    abort("`delay_mouseout` must be a scalar positive number", call = NULL)
  }

  x <- list(
    position = position,
    pngname = pngname,
    tooltips = tooltips,
    hidden = hidden,
    delay_over = delay_mouseover,
    delay_out = delay_mouseout
  )
  class(x) <- "opts_toolbar"
  x
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
opts_sizing <- function(rescale = TRUE, width = 1){
  if (!is_valid_logical(rescale)) {
    abort("`rescale` must be a scalar logical")
  }
  if (!is_valid_number(width) || width <= 0 || width > 1) {
    abort("`width` must be a scalar number, (0 < width <= 1)", call = NULL)
  }

  x <- list(rescale = rescale, width = width)
  class(x) <- "opts_sizing"
  x
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
#' @family girafe animation options
girafe_options <- function(x, ...){
  if(!inherits(x, "girafe")) {
    abort("`x` must be a girafe object", call = NULL)
  }

  args <- list(...)
  x$x$settings <- merge_options(x$x$settings, args)
  x$sizingPolicy <- merge_sizing_policy(x$sizingPolicy, args)
  x
}

merge_options <- function(options, args){
  for (arg in args) {
    if (inherits(arg, "opts_zoom")) {
      options$zoom <- arg
    } else if (inherits(arg, "opts_selection")) {
      options$select <- arg
    } else if (inherits(arg, "opts_selection_inv")) {
      options$select_inv <- arg
    } else if (inherits(arg, "opts_selection_key")) {
      options$select_key <- arg
    } else if (inherits(arg, "opts_selection_theme")) {
      options$select_theme <- arg
    } else if (inherits(arg, "opts_tooltip")) {
      options$tooltip <- arg
    } else if (inherits(arg, "opts_hover")) {
      options$hover <- arg
    } else if (inherits(arg, "opts_hover_key")) {
      options$hover_key <- arg
    } else if (inherits(arg, "opts_hover_theme")) {
      options$hover_theme <- arg
    } else if (inherits(arg, "opts_hover_inv")) {
      options$hover_inv <- arg
    } else if (inherits(arg, "opts_toolbar")) {
      options$toolbar <- arg
    } else if (inherits(arg, "opts_sizing")) {
      options$sizing <- arg
    }
  }
  options
}

merge_sizing_policy <- function(policy, args) {
  for (arg in args) {
    if (is.list(arg) && all(names(arg) %in% names(htmlwidgets::sizingPolicy()))) {
      policy <- arg
    }
  }
  policy
}

default_opts <- function(){
  list(
    tooltip = girafe_defaults("opts_tooltip"),
    hover = girafe_defaults("opts_hover"),
    hover_inv = girafe_defaults("opts_hover_inv"),
    hover_key = girafe_defaults("opts_hover_key"),
    hover_theme = girafe_defaults("opts_hover_theme"),
    select = girafe_defaults("opts_selection"),
    select_inv = girafe_defaults("opts_selection_inv"),
    select_key = girafe_defaults("opts_selection_key"),
    select_theme = girafe_defaults("opts_selection_theme"),
    zoom = girafe_defaults("opts_zoom"),
    toolbar = girafe_defaults("opts_toolbar"),
    sizing = girafe_defaults("opts_sizing")
  )
}

default_sizing_policy <- function() {
  sizingPolicy(knitr.figure = TRUE, browser.fill = FALSE)
}

