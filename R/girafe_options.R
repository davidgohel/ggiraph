#' @title tooltip settings
#' @description Settings to be used with \code{\link{girafe}}
#' for tooltip customisation.
#' @param css extra css (added to \code{position: absolute;pointer-events: none;})
#' used to customize tooltip area.
#' @param use_cursor_pos should the cursor position be used to
#' position tooltip (in addition to offx and offy).
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
#' @seealso set options with \code{\link{girafe_options}}
opts_tooltip <- function(
  css = NULL, offx = 10, offy = 0, use_cursor_pos = TRUE,
  opacity = .9, use_fill = FALSE, use_stroke = FALSE,
  delay_mouseover = 200, delay_mouseout = 500, zindex = 999){

  if( is.null(css)){
    css <- "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;"
  }
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

  css <- paste0("{position:absolute;pointer-events:none;",
                sprintf("z-index:%.0f;", zindex),
                css, "}")
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

#' @title hover effect settings
#' @description Allows customization of the animation
#' of graphic elements on which the mouse is positioned.
#' @param css css to associate with elements to be animated
#' when mouse is hover them.
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
#' @seealso set options with \code{\link{girafe_options}}
opts_hover <- function(css = NULL){

  if( is.null(css)){
    css <- "fill:orange;stroke:gray;"
  }
  css <- paste0("{", css, "}")
  x <- list(
    css = css
  )
  class(x) <- "opts_hover"
  x
}

#' @title selection effect settings
#' @description Allows customization of the rendering of
#' selected graphic elements.
#' @param css css to associate with elements when they are selected.
#' @param type selection mode ("single", "multiple", "none")
#'  when widget is in a Shiny application.
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
#' @seealso set options with \code{\link{girafe_options}}
opts_selection <- function(css = NULL, type = "multiple"){

  if( is.null(css)){
    css <- "fill:red;stroke:gray;"
  }

  stopifnot(type %in%
              c("single", "multiple", "none"))

  css <- paste0("{", css, "}")
  x <- list(
    css = css,
    type = type
  )
  class(x) <- "opts_selection"
  x
}

#' @title zoom settings
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
#' @seealso set options with \code{\link{girafe_options}}
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

#' @title toolbar settings
#' @description Allows customization of the toolbar
#' @param position one of 'top', 'bottom', 'topleft', 'topright', 'bottomleft', 'bottomright'
#' @param saveaspng set to TRUE to propose the 'save as png' button.
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
#' @seealso set options with \code{\link{girafe_options}}
opts_toolbar <- function(position = "topright", saveaspng = TRUE){

  stopifnot(position %in% c("top", "bottom",
                            "topleft", "topright",
                            "bottomleft", "bottomright") )

  x <- list(
    position = position,
    saveaspng = saveaspng
  )
  class(x) <- "opts_toolbar"
  x
}

#' @title set girafe options
#' @description Defines the animation options related to
#' a \code{\link{girafe}} object.
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
#' @seealso \code{\link{opts_tooltip}}, \code{\link{opts_hover}},
#' \code{\link{opts_selection}}, \code{\link{opts_zoom}}, \code{\link[htmlwidgets]{sizingPolicy}}
girafe_options <- function(x, ...){
  stopifnot(inherits(x, "girafe"))

  args <- list(...)
  for( arg in args ){
    if( inherits(arg, "opts_zoom")){
      x$x$settings$zoom <- arg
    } else if( inherits(arg, "opts_selection")){
      x$x$settings$capture <- arg
    } else if( inherits(arg, "opts_tooltip")){
      x$x$settings$tooltip <- arg
    } else if( inherits(arg, "opts_hover")){
      x$x$settings$hover <- arg
    } else if( inherits(arg, "opts_toolbar")){
      x$x$settings$toolbar <- arg
    } else if( all( names( arg ) %in% c("defaultWidth", "defaultHeight", "padding", "viewer", "browser",
                                  "knitr") ) ){
      x$sizingPolicy <- arg
    }
  }
  x
}


