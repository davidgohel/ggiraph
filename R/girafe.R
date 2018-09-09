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

girafe <- function(code, ggobj = NULL,
                    pointsize = 12,
                    width = 0.95,
                    width_svg = 6, height_svg = 5,
                    tooltip_extra_css,
                    hover_css,
                    tooltip_opacity = .9,
                    tooltip_offx = 10,
                    tooltip_offy = 0,
                    tooltip_zindex = 999,
                    zoom_max = 1,
                    selection_type = "multiple",
                    selected_css,
                    dep_dir = NULL,
                    xml_reader_options = list(),
                    ...) {


  if( missing( tooltip_extra_css ))
    tooltip_extra_css <- "padding:5px;background:black;color:white;border-radius:2px 2px 2px 2px;"
  if( missing( hover_css ))
    hover_css <- "fill:orange;stroke:gray;"
  if( missing( selected_css ))
    selected_css <- hover_css

  stopifnot( is.numeric(width), width > 0, width <= 1 )

  stopifnot(selection_type %in% c("single", "multiple", "none"))
  stopifnot(is.numeric(tooltip_offx))
  stopifnot(is.numeric(tooltip_offy))
  stopifnot(is.numeric(tooltip_opacity))
  stopifnot(tooltip_opacity > 0 && tooltip_opacity <= 1)
  stopifnot(tooltip_opacity > 0 && tooltip_opacity <= 1)
  stopifnot(is.numeric(zoom_max))

  if( zoom_max < 1 )
    stop("zoom_max should be >= 1")

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

  if( grepl(x = tooltip_extra_css, pattern = "position[ ]*:") )
    stop("please, do not specify position in tooltip_extra_css, this parameter is managed by girafe.")
  if( grepl(x = tooltip_extra_css, pattern = "pointer-events[ ]*:") )
    stop("please, do not specify pointer-events in tooltip_extra_css, this parameter is managed by girafe.")

  unlink(path)

  if ( is.null(dep_dir) ) {
    dep_dir <- tempfile()
    dir.create(dep_dir)
  } else {
    if ( !dir.exists(dep_dir) )
      stop(dep_dir, " does not exist.", call. = FALSE)
  }

  class_selected_name <- paste0("clicked_", svg_id)
  class_hover_id <- paste0("hover_", svg_id)

  css <- paste0(".tooltip_", svg_id,
                sprintf( " {position:absolute;pointer-events:none;z-index:%.0f;", tooltip_zindex),
                tooltip_extra_css, "}\n",
                ".", class_hover_id, "{", hover_css, "}\n",
                ".", class_selected_name, "{", selected_css, "}"
  )

  x = list( html = as.character(data), css = css, js = js,
            uid = svg_id, width = sprintf( "%.0f%%", width * 100 ),
            tooltip_opacity = tooltip_opacity,
            tooltip_offx = tooltip_offx, tooltip_offy = tooltip_offy,
            zoom_max = zoom_max,
            selection_type = selection_type)

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
#' @param expr An expression that returns a \code{\link{}} object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @export
renderGirafe <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, girafeOutput, env, quoted = TRUE)
}


tooltip_settings <- function(x, css, opacity = .9, offx = 10, offy = 0, zindex){

}

