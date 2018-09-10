#' @importFrom rvg dsvg rvg_tracer_on rvg_tracer_off set_attr
#' @importFrom htmltools htmlDependency
#' @importFrom htmlwidgets shinyRenderWidget shinyWidgetOutput sizingPolicy createWidget
#' @import grid
#' @import ggplot2
#' @importFrom grDevices dev.off
#' @importFrom xml2 read_xml xml_find_all xml_text xml_ns
#' @importFrom xml2 xml_remove xml_attr xml_attr<-

#' @title create a ggiraph object
#'
#' @description Create an interactive graphic to be used in a web browser.
#'
#' Use \code{geom_zzz_interactive} to create interactive graphical elements.
#'
#' Difference from original functions is that the following
#' aesthetics are understood: \code{tooltip}, \code{onclick}
#' and \code{data_id}.
#'
#' Tooltips can be displayed when mouse is over graphical elements.
#'
#' If id are associated with points, they get animated when mouse is
#' over and can be selected when used in shiny apps.
#'
#' On click actions can be set with javascript instructions. This option
#' should not be used simultaneously with selections in Shiny
#' applications as both features are "on click" features.
#'
#' When \code{zoom_max} is set, "zoom activate", "zoom desactivate" and
#' "zoom init" buttons are available in a toolbar.
#'
#' When \code{selection} is set to multiple (in Shiny applications), lasso
#' selection and lasso anti-selections buttons are available in a toolbar.
#'
#' @param code Plotting code to execute
#' @param ggobj ggplot objet to print. argument \code{code} will
#' be ignored if this argument is supplied.
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param width_svg,height_svg The width and height of the graphics region in inches.
#' The default values are 6 and 5 inches. This will define the aspect ratio of the
#' graphic as it will be used to define viewbox attribute of the SVG result.
#' @param tooltip_extra_css extra css (added to \code{position: absolute;pointer-events: none;})
#' used to customize tooltip area.
#' @param hover_css css to apply when mouse is hover and element with a data-id attribute.
#' @param tooltip_opacity tooltip opacity
#' @param tooltip_offx tooltip x offset
#' @param tooltip_offy tooltip y offset
#' @param tooltip_zindex tooltip css z-index, default to 999.
#' @param zoom_max maximum zoom factor
#' @param selection_type row selection mode ("single", "multiple", "none")
#'  when widget is in a Shiny application.
#' @param selected_css css to apply when element is selected (shiny only).
#' @param width widget width ratio (0 < width <= 1). Unused within shiny
#' applications or flexdashboard documents. See below.
#' @param dep_dir the path where the output files are stored. If \code{NULL},
#'  the current path for temporary files is used.
#' @param xml_reader_options read_xml additional arguments to be used
#' when parsing the svg result. This feature can be used to parse
#' huge svg files by using \code{list(options = "HUGE")} but this
#' is not recommanded.
#' @param ... arguments passed on to \code{\link[rvg]{dsvg}}
#' @examples
#' # ggiraph simple example -------
#' @example examples/geom_point_interactive.R
#' @section Widget sizing:
#' ggiraph graphics are responsive, which mean, they will be resized
#' according to their container. There are two responsive behavior
#' implementation: one for Shiny applications and flexdashboard documents
#' and one for other documents (i.e. R markdown and \code{saveWidget}).
#'
#' When a ggiraph graphic is in a Shiny application or in a flexdashboard
#' graphic will be resized according to the arguments \code{width} and
#' \code{height} of the function \code{ggiraphOutput}. Default
#' values are '100%' and '500px'. These arguments determine the
#' outer bounding box (and \code{width_svg} and \code{height_svg}
#' determines the proportions.
#'
#' When a ggiraph graphic is in an R markdown document (producing an HTML
#' document), the graphic will be resized according to the argument \code{width} of the
#' function \code{ggiraph}. Its value is beeing used to define a relative
#' width of the graphic within its HTML container. Its height is automatically
#' adjusted regarding to the argument \code{width} and the ratio between
#' \code{width_svg} and \code{height_svg}.
#'
#' If this behavior does not fit with your need, I recommand you to use
#' package widgetframe that wraps htmlwidgets inside a responsive iframe.
#' @export
ggiraph <- function(code, ggobj = NULL,
                    pointsize = 12,
                    width = .75,
                    width_svg = 6, height_svg = 5,
                    tooltip_extra_css = NULL,
                    hover_css = NULL,
                    tooltip_opacity = .9,
                    tooltip_offx = 10,
                    tooltip_offy = 0,
                    tooltip_zindex = 999,
                    zoom_max = 1,
                    selection_type = "multiple",
                    selected_css = NULL,
                    dep_dir = NULL,
                    xml_reader_options = list(),
                    ...) {

  if( !missing(dep_dir) ){
    warning("argument `dep_dir` has been deprecated.")
  }


  x <- girafe(code = code, ggobj = ggobj, width = width, pointsize = pointsize,
         width_svg = width_svg, height_svg = height_svg, xml_reader_options = xml_reader_options, ...)
  x <- girafe_options(
    x = x,
    opt_tooltip(css = tooltip_extra_css,
                opacity = tooltip_opacity,
                offx = tooltip_offx, offy = tooltip_offy,
                delay_mouseover = 200, delay_mouseout = 500,
                zindex = tooltip_zindex),
    opt_zoom(min = 1, max = zoom_max),
    opt_selection(type = selection_type, css = selected_css),
    opt_hover(css = hover_css)
    )

  # fix for package ceterisParibus unit tests
  class(x) <- unique( c(class(x), "ggiraph"))

  x
}



#' @title Create a ggiraph output element
#' @description Render a ggiraph within an application page.
#'
#' @param outputId output variable to read the ggiraph from.
#' @param width widget width
#' @param height widget height
#' @examples
#' \dontrun{
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny/cars" )
#'   shinyAppDir(appDir = app_dir )
#'  }
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny/crimes" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' }
#' @export
ggiraphOutput <- function(outputId, width = "100%", height = "500px"){
  if( "auto" %in% height )
    stop("'height:auto' is not supported", call. = FALSE)
  if( "auto" %in% width )
    stop("'width:auto' is not supported", call. = FALSE)

  shinyWidgetOutput(outputId, 'girafe', package = 'ggiraph', width = width, height = height)
}

#' @title Reactive version of ggiraph object
#'
#' @description Makes a reactive version of a ggiraph object for use in Shiny.
#'
#' @param expr An expression that returns a \code{\link{ggiraph}} object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @examples
#' \dontrun{
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' }
#' @export
renderggiraph <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, girafeOutput, env, quoted = TRUE)
}









