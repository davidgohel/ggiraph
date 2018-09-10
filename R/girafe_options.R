#' @title settings for tooltip
#' @description Settings to be used with \code{\link{girafe}}
#' for tooltip customisation.
#' @param css extra css (added to \code{position: absolute;pointer-events: none;})
#' used to customize tooltip area.
#' @param opacity tooltip background opacity
#' @param delay_mouseover The duration in milliseconds of the
#' transition associated with tooltip display.
#' @param delay_mouseout The duration in milliseconds of the
#' transition associated with tooltip end of display.
#' @param offx,offy tooltip x and y offset
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
#'   opt_tooltip(opacity = .7,
#'     offx = 20, offy = -10,
#'     delay_mouseout = 1000) )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
#' @seealso set options with \code{\link{girafe_options}}
opt_tooltip <- function(
  css = NULL, offx = 10, offy = 0, opacity = .9,
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
    opacity = opacity,
    delay = list(over = delay_mouseover,
                 out = delay_mouseout)
  )
  class(x) <- "opt_tooltip"
  x
}

#' @title hover effect
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
#'   opt_hover(css = "fill:wheat;stroke:orange;r:5pt;") )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
#' @seealso set options with \code{\link{girafe_options}}
opt_hover <- function(css = "fill:orange;stroke:gray;"){

  css <- paste0("{", css, "}")
  x <- list(
    css = css
  )
  class(x) <- "opt_hover"
  x
}

#' @title hover effect
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
#'   opt_selection(type = "multiple",
#'     css = "fill:red;stroke:gray;r:5pt;") )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
#' @seealso set options with \code{\link{girafe_options}}
opt_selection <- function(
  css = "fill:red;stroke:gray;",
  type = "multiple"){

  stopifnot(type %in%
              c("single", "multiple", "none"))

  css <- paste0("{", css, "}")
  x <- list(
    css = css,
    type = type
  )
  class(x) <- "opt_selection"
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
#'   opt_zoom(min = .7, max = 2) )
#' if( interactive() ) print(x)
#' @export
#' @family girafe animation options
#' @seealso set options with \code{\link{girafe_options}}
opt_zoom <- function(min = 1, max = 1){

  stopifnot(is.numeric(min), is.numeric(max))

  if( max < .2 )
    stop("max should be >= 0.2")
  if( max < min )
    stop("max should > min")

  x <- list(
    min = min,
    max = max
  )
  class(x) <- "opt_zoom"
  x
}

#' @title set girafe options
#' @description Defines the animation options related to
#' a \code{\link{girafe}} object.
#' @param x girafe object.
#' @param ... set of options defined by calls to \code{opt_*} functions.
#' @examples
#' library(ggplot2)
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
#'     opt_tooltip(opacity = .7),
#'     opt_zoom(min = .5, max = 4),
#'     opt_hover(css = "fill:red;stroke:orange;r:5pt;") )
#'
#' if(interactive()){
#'   print(x)
#' }
#' @export
#' @seealso \code{\link{opt_tooltip}}, \code{\link{opt_hover}},
#' \code{\link{opt_selection}}, \code{\link{opt_zoom}}
girafe_options <- function(x, ...){
  stopifnot(inherits(x, "girafe"))

  args <- list(...)
  for( arg in args ){
    if( inherits(arg, "opt_zoom")){
      x$x$settings$zoom <- arg
    } else if( inherits(arg, "opt_selection")){
      x$x$settings$capture <- arg
    } else if( inherits(arg, "opt_tooltip")){
      x$x$settings$tooltip <- arg
    } else if( inherits(arg, "opt_hover")){
      x$x$settings$hover <- arg
    }
  }
  x
}


