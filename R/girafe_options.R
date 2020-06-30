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
                         zindex = 999) {
  css <- check_css(
    css = css,
    default = "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px",
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

  css <- sub("\\}\n$",
             paste0(
               "; position:absolute;pointer-events:none;",
               sprintf("z-index:%.0f;", zindex),
               "}\n"
             ),
             css)
  x <- list(
    css = css,
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
#' Use \code{opts_hover} for interactive geometries in panels,
#' \code{opts_hover_key} for interactive scales/guides and
#' \code{opts_hover_theme} for interactive theme elements.
#' Use \code{opts_hover_inv} for the effect on the rest of the geometries,
#' while one is hovered (inverted operation).
#' @param css css to associate with elements when they are hovered.
#' It must be a scalar character. It can also be constructed with
#' \code{\link{girafe_css}}, to give more control over the css for different element types.
#' @param reactive if TRUE, in Shiny context, hovering will set Shiny input values.
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
                       reactive = FALSE) {
  css <- check_css(css,
                   default = "fill:orange;stroke:gray;",
                   cls_prefix = "hover_",
                   name = "opts_hover")
  structure(list(css = css, reactive = reactive),
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
#' Use \code{opts_selection} for interactive geometries in panels,
#' \code{opts_selection_key} for interactive scales/guides and
#' \code{opts_selection_theme} for interactive theme elements.
#' @param css css to associate with elements when they are selected.
#' It must be a scalar character. It can also be constructed with
#' \code{\link{girafe_css}}, to give more control over the css for different element types.
#' @param type selection mode ("single", "multiple", "none")
#'  when widget is in a Shiny application.
#' @param only_shiny disable selections if not in a shiny context.
#' @param selected character vector, id to be selected when the graph will be
#' initialized.
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
#'   opts_selection(type = "multiple",
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
#' \code{saveaspng} relies on JavaScript promises, so any browsers that don't natively
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
#' @param rescale if FALSE, graphic will not be resized
#' and the dimensions are exactly those of the container.
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

  for (arg in args) {
    if (all(names(arg) %in% c("defaultWidth", "defaultHeight", "padding", "viewer", "browser", "knitr"))) {
      x$sizingPolicy <- arg
    }
  }
  x
}


