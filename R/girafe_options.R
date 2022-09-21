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
                         placement = "auto",
                         zindex = 999) {
  css <- check_css(
    css = css,
    default = "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;text-align:left;",
    cls_prefix = "tooltip_",
    name = "opts_tooltip"
  )
  if( grepl(x = css, pattern = "position[ ]*:") )
    stop("do not specify position in css, this parameter is managed by girafe.")
  if( grepl(x = css, pattern = "pointer-events[ ]*:") )
    stop("do not specify pointer-events in css, this parameter is managed by girafe.")

  stopifnot(is.numeric(offx),
            is.numeric(offy),
            is.numeric(opacity),
            is.numeric(zindex)
  )
  stopifnot(opacity > 0 && opacity <= 1)
  stopifnot(zindex >= 1)
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

  stopifnot(placement %in% c("auto", "doc", "container"))
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
    offx = offx, offy = offy,
    use_cursor_pos = use_cursor_pos,
    opacity = opacity,
    usefill = use_fill, usestroke = use_stroke,
    delay = list(over = delay_mouseover,
                 out = delay_mouseout)
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
opts_hover <- function(css = NULL,
                       reactive = FALSE,
                       nearest_distance = NULL) {
  if (!is.null(nearest_distance)) {
    if (!(
      rlang::is_scalar_integer(nearest_distance) ||
      rlang::is_scalar_double(nearest_distance)
    ) || is.nan(nearest_distance) || is.na(nearest_distance) || nearest_distance < 0) {
      stop("`nearest_distance` must be a scalar positive number or NULL", call. = FALSE)
    }
  }
  css <- check_css(css,
                   default = "fill:orange;stroke:gray;",
                   cls_prefix = "hover_",
                   name = "opts_hover")
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
opts_selection <- function(css = NULL,
                           type = "multiple",
                           only_shiny = TRUE,
                           selected = character(0)) {
  css <- check_css(css,
                   default = "fill:red;stroke:gray;",
                   cls_prefix = "selected_",
                   name = "opts_selection")
  stopifnot(type %in%
              c("single", "multiple", "none"))
  structure(list(
    css = css,
    type = type,
    only_shiny = only_shiny,
    selected = selected
  ),
  class = "opts_selection")
}

#' @export
#' @rdname opts_selection
opts_selection_inv <- function(css = NULL) {
  css <- check_css(css,
                   default = "",
                   cls_prefix = "selected_inv_",
                   name = "opts_selection_inv")
  structure(list(css = css),
            class = "opts_selection_inv")
}

#' @export
#' @rdname opts_selection
opts_selection_key <- function(css = NULL,
                               type = "single",
                               only_shiny = TRUE,
                               selected = character(0)) {
  css <- check_css(css,
                   default = "stroke:gray;",
                   cls_prefix = "selected_key_",
                   name = "opts_selection_key")
  stopifnot(type %in%
              c("single", "multiple", "none"))
  structure(list(
    css = css,
    type = type,
    only_shiny = only_shiny,
    selected = selected
  ),
  class = "opts_selection_key")
}

#' @export
#' @rdname opts_selection
opts_selection_theme <- function(css = NULL,
                                 type = "single",
                                 only_shiny = TRUE,
                                 selected = character(0)) {
  css <- check_css(css,
                   default = "stroke:gray;",
                   cls_prefix = "selected_theme_",
                   name = "opts_selection_theme")
  stopifnot(type %in%
              c("single", "multiple", "none"))
  structure(list(
    css = css,
    type = type,
    only_shiny = only_shiny,
    selected = selected
  ),
  class = "opts_selection_theme")
}

#' @title Zoom settings
#' @description Allows customization of the zoom.
#' @param min minimum zoom factor
#' @param max maximum zoom factor
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
opts_zoom <- function(min = 1, max = 1){

  stopifnot(is.numeric(min), is.numeric(max))

  if( max < .2 )
    stop("max should be >= 0.2")
  if( max < min )
    stop("max should > min")

  x <- list(
    min = min,
    max = max
  )
  class(x) <- "opts_zoom"
  x
}

#' @title Toolbar settings
#' @description Allows customization of the toolbar
#' @param position one of 'top', 'bottom', 'topleft', 'topright', 'bottomleft', 'bottomright'
#' @param saveaspng set to TRUE to propose the 'save as png' button.
#' @param pngname the default basename (without .png extension) to use for the png file.
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
opts_toolbar <- function(position = "topright", saveaspng = TRUE, pngname = "diagram"){

  stopifnot(position %in% c("top", "bottom",
                            "topleft", "topright",
                            "bottomleft", "bottomright") )
  stopifnot(is.character(pngname))
  x <- list(
    position = position,
    saveaspng = saveaspng,
    pngname = pngname
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
  if( !is.logical(rescale) || length(rescale) != 1L ){
    stop("parameter rescale should be a scalar logical")
  } else rescale <- as.logical(rescale)
  if( !is.numeric(width) || length(width) != 1L ){
    stop("parameter width should be a scalar double")
  } else width <- as.double(width)

  stopifnot(width > 0, width <= 1 )

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
#' @seealso [girafe()]
#' @family girafe animation options
girafe_options <- function(x, ...){
  stopifnot(inherits(x, "girafe"))

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
      options$capture <- arg
    } else if (inherits(arg, "opts_selection_inv")) {
      options$captureinv <- arg
    } else if (inherits(arg, "opts_selection_key")) {
      options$capturekey <- arg
    } else if (inherits(arg, "opts_selection_theme")) {
      options$capturetheme <- arg
    } else if (inherits(arg, "opts_tooltip")) {
      options$tooltip <- arg
    } else if (inherits(arg, "opts_hover")) {
      options$hover <- arg
    } else if (inherits(arg, "opts_hover_key")) {
      options$hoverkey <- arg
    } else if (inherits(arg, "opts_hover_theme")) {
      options$hovertheme <- arg
    } else if (inherits(arg, "opts_hover_inv")) {
      options$hoverinv <- arg
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
    if (is.list(arg) && all(names(arg) %in% c(
      "defaultWidth", "defaultHeight", "padding",
      "viewer", "browser", "knitr"
    ))) {
      policy <- arg
    }
  }
  policy
}

default_opts <- function(){
  list(
    tooltip = opts_tooltip(),
    hover = opts_hover(),
    hoverkey = opts_hover_key(),
    hovertheme = opts_hover_theme(),
    hoverinv = opts_hover_inv(),
    zoom = opts_zoom(),
    capture = opts_selection(),
    captureinv = opts_selection_inv(),
    capturekey = opts_selection_key(),
    capturetheme = opts_selection_theme(),
    toolbar = opts_toolbar(),
    sizing = opts_sizing()
  )
}

default_sizing_policy <- function() {
  sizingPolicy(knitr.figure = TRUE, browser.fill = FALSE)
}

