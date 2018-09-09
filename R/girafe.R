#' @title create a girafe object
#'
#' @description Create an interactive graphic to be used in a web browser.
#'
#' @param code Plotting code to execute
#' @param ggobj ggplot objet to print. argument \code{code} will
#' be ignored if this argument is supplied.
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param width_svg,height_svg The width and height of the graphics region in inches.
#' The default values are 6 and 5 inches. This will define the aspect ratio of the
#' graphic as it will be used to define viewbox attribute of the SVG result.
#' @param width widget width ratio (0 < width <= 1). Unused within shiny
#' applications or flexdashboard documents. See below.
#' @param xml_reader_options read_xml additional arguments to be used
#' when parsing the svg result. This feature can be used to parse
#' huge svg files by using \code{list(options = "HUGE")} but this
#' is not recommanded.
#' @param ... arguments passed on to \code{\link[rvg]{dsvg}}
#' @examples
#' # girafe simple example -------
#' @example examples/geom_point_interactive.R
#' @section Widget sizing:
#' girafe graphics are responsive, which mean, they will be resized
#' according to their container. There are two responsive behavior
#' implementation: one for Shiny applications and flexdashboard documents
#' and one for other documents (i.e. R markdown and \code{saveWidget}).
#'
#' When a girafe graphic is in a Shiny application or in a flexdashboard
#' graphic will be resized according to the arguments \code{width} and
#' \code{height} of the function \code{girafeOutput}. Default
#' values are '100%' and '500px'. These arguments determine the
#' outer bounding box (and \code{width_svg} and \code{height_svg}
#' determines the proportions.
#'
#' When a girafe graphic is in an R markdown document (producing an HTML
#' document), the graphic will be resized according to the argument \code{width} of the
#' function \code{girafe}. Its value is beeing used to define a relative
#' width of the graphic within its HTML container. Its height is automatically
#' adjusted regarding to the argument \code{width} and the ratio between
#' \code{width_svg} and \code{height_svg}.
#'
#' If this behavior does not fit with your need, I recommand you to use
#' package widgetframe that wraps htmlwidgets inside a responsive iframe.
#' @export
girafe <- function(code, ggobj = NULL, pointsize = 12,
                   width = 0.95,
                   width_svg = 6, height_svg = 5,
                   xml_reader_options = list(), ...) {

  stopifnot( is.numeric(width), width > 0, width <= 1 )

  ggiwid.options = getOption("ggiwid")
  tmpdir = tempdir()
  path = tempfile()
  canvas_id <- ggiwid.options$svgid
  dsvg(file = path, pointsize = pointsize, standalone = TRUE,
       width = width_svg, height = height_svg,
       canvas_id = canvas_id, ...
  )
  tryCatch({
    if( !is.null(ggobj) ){
      stopifnot(inherits(ggobj, "ggplot"))
      print(ggobj)
    } else
      code
  }, finally = dev.off() )

  ggiwid.options$svgid = 1 + ggiwid.options$svgid
  options("ggiwid"=ggiwid.options)

  xml_reader_options$x <- path
  data <- do.call(read_xml, xml_reader_options )
  scr <- xml_find_all(data, "//*[@type='text/javascript']", ns = xml_ns(data) )
  js <- paste( sapply( scr, xml_text ), collapse = ";")
  js <- paste0("function zzz(){", js, "};")
  xml_remove(scr)
  xml_attr(data, "width") <- NULL
  xml_attr(data, "height") <- NULL
  svg_id <- xml_attr(data, "id")

  unlink(path)

  tooltip_set <- tooltip_settings()
  hover_set <- hover_settings()
  zoom_set <- zoom_settings()
  selection_set <- selection_settings()

  x = list( html = as.character(data), js = js,
            uid = svg_id, width = width,
            ratio = width_svg / height_svg,
            settings = list(
              tooltip = tooltip_set,
              hover = hover_set,
              zoom = zoom_set,
              capture = selection_set
              )
            )

  createWidget(
    name = 'girafe', x = x, package = 'ggiraph',
    sizingPolicy = sizingPolicy(knitr.figure = TRUE, browser.fill = FALSE)
  )

}



#' @title Create a girafe output element
#' @description Render a girafe within an application page.
#'
#' @param outputId output variable to read the girafe from.
#' @param width widget width
#' @param height widget height
#' @export
girafeOutput <- function(outputId, width = "100%", height = "500px"){
  if( "auto" %in% height )
    stop("'height:auto' is not supported", call. = FALSE)
  if( "auto" %in% width )
    stop("'width:auto' is not supported", call. = FALSE)

  shinyWidgetOutput(outputId, 'girafe', package = 'ggiraph', width = width, height = height)
}

#' @title Reactive version of girafe
#'
#' @description Makes a reactive version of a  object for use in Shiny.
#'
#' @param expr An expression that returns a \code{\link{girafe}} object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @export
renderGirafe <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, girafeOutput, env, quoted = TRUE)
}

#' @title settings for tooltip
#' @description settings to be used with \code{\link{girafe}}
#' for tooltip customisation.
#' @param css extra css (added to \code{position: absolute;pointer-events: none;})
#' used to customize tooltip area.
#' @param opacity tooltip opacity
#' @param delay_mouseover delai
#' @param delay_mouseout delai opacity
#' @param offx tooltip x offset
#' @param offy tooltip y offset
#' @param zindex tooltip css z-index, default to 999.
#' @export
tooltip_settings <- function(css = "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;",
                             offx = 10, offy = 0,
                             opacity = .9,
                             delay_mouseover = 200,
                             delay_mouseout = 500,
                             zindex = 999){

  if( grepl(x = css, pattern = "position[ ]*:") )
    stop("please, do not specify position in css, this parameter is managed by girafe.")
  if( grepl(x = css, pattern = "pointer-events[ ]*:") )
    stop("please, do not specify pointer-events in css, this parameter is managed by girafe.")

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
  class(x) <- "tooltip_settings"
  x
}

#' @title hover effect
#' @description Allows customization of the animation
#' of graphic elements on which the mouse is positioned.
#' @param css extra css used to customize animation.
#' @export
hover_settings <- function(css = "fill:orange;stroke:gray;"){

  css <- paste0("{", css, "}")
  x <- list(
    css = css
  )
  class(x) <- "hover_settings"
  x
}

#' @export
#' @title hover effect
#' @description Allows customization of the rendering of
#' selected graphic elements.
#' @param css extra css used to customize animation.
#' @param type selection mode ("single", "multiple", "none")
#'  when widget is in a Shiny application.
selection_settings <- function(
  css = "fill:red;stroke:gray;",
  type = "multiple"){

  stopifnot(type %in%
              c("single", "multiple", "none"))

  css <- paste0("{", css, "}")
  x <- list(
    css = css,
    type = type
  )
  class(x) <- "selection_settings"
  x
}

#' @export
#' @title zoom settings
#' @description Allows customization of the zoom.
#' @param min minimum zoom factor
#' @param max maximum zoom factor
zoom_settings <- function(min = 1, max = 1){

  stopifnot(is.numeric(min), is.numeric(max))

  if( max < .2 )
    stop("max should be >= 0.2")
  if( max < min )
    stop("max should > min")

  x <- list(
    min = min,
    max = max
  )
  class(x) <- "zoom_settings"
  x
}

#' @export
girafe_settings <- function(x, ...){
  stopifnot(inherits(x, "girafe"))

  args <- list(...)
  for( arg in args ){
    if( inherits(arg, "zoom_settings")){
      x$x$settings$zoom <- arg
    } else if( inherits(arg, "selection_settings")){
      x$x$settings$capture <- arg
    } else if( inherits(arg, "tooltip_settings")){
      x$x$settings$tooltip <- arg
    } else if( inherits(arg, "hover_settings")){
      x$x$settings$hover <- arg
    }
  }
  x
}


