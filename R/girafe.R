#' @title create a girafe object
#'
#' @description Create an interactive graphic with a ggplot object
#' to be used in a web browser. The function should replace function
#' \code{ggiraph}.
#'
#' @details
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
#' When a zoom effect is set, "zoom activate", "zoom desactivate" and
#' "zoom init" buttons are available in a toolbar.
#'
#' When selection type is set to 'multiple' (in Shiny applications), lasso
#' selection and lasso anti-selections buttons are available in a toolbar.
#'
#' @param code Plotting code to execute
#' @param ggobj ggplot objet to print. argument \code{code} will
#' be ignored if this argument is supplied.
#' @param width widget width ratio (0 < width <= 1). See below in section .
#' @param width_svg,height_svg The width and height of the graphics region in inches.
#' The default values are 6 and 5 inches. This will define the aspect ratio of the
#' graphic as it will be used to define viewbox attribute of the SVG result.
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param xml_reader_options read_xml additional arguments to be used
#' when parsing the svg result. This feature can be used to parse
#' huge svg files by using \code{list(options = "HUGE")} but this
#' is not recommanded.
#' @param ... arguments passed on to \code{\link{dsvg}}
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
#' x <- girafe(ggobj = gg_point, width = 0.7)
#'
#' if(interactive()){
#'   print(x)
#' }
#' @section Widget options:
#' girafe animations can be customized with function \code{\link{girafe_options}}.
#' Options are available to customize tooltips, hover effects, zoom effects
#' selection effects and toolbar.
#' @section Widget sizing:
#' girafe graphics are responsive, which mean, they will be resized
#' according to their container. There are two responsive behavior
#' implementations: one for Shiny applications and flexdashboard documents
#' and one for other documents (i.e. R markdown and \code{saveWidget}).
#'
#' Graphics are created by an R graphic device (i.e pdf, png, svg here) and
#' need arguments width and height to define a graphic region.
#' Arguments \code{width_svg} and \code{height_svg} are used as corresponding
#' values. They are defining the aspect ratio of the graphic. This proportion is
#' always respected when the graph is displayed.
#'
#' When a girafe graphic is in a Shiny application,
#' graphic will be resized according to the arguments \code{width} and
#' \code{height} of the function \code{girafeOutput}. Default
#' values are '100\%' and '500px'. These arguments determine the
#' outer bounding box of the graphic (the HTML element that will
#' contain the graphic with an aspect ratio).
#'
#' When a girafe graphic is in an R markdown document (producing an HTML
#' document), the graphic will be resized according to the argument \code{width} of the
#' function \code{girafe}. Its value is beeing used to define a relative
#' width of the graphic within its HTML container. Its height is automatically
#' adjusted regarding to the argument \code{width} and the aspect ratio.
#'
#' If this behavior does not fit with your need, I recommand you to use
#' package widgetframe that wraps htmlwidgets inside a responsive iframe.
#' @seealso \code{\link{girafe_options}}
#' @export
girafe <- function(
  code, ggobj = NULL,  width = 0.9, pointsize = 12,
  width_svg = 6, height_svg = 5, xml_reader_options = list(), ...) {

  stopifnot( is.numeric(width), width > 0, width <= 1 )
  canvas_id <- basename( tempfile(pattern = "svg_", fileext = format(Sys.time(), "%Y%m%d%H%M%S") ) )
  path = tempfile()
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

  xml_reader_options$x <- path
  data <- do.call(read_xml, xml_reader_options )
  scr <- xml_find_all(data, "//*[@type='text/javascript']", ns = xml_ns(data) )
  js <- paste( sapply( scr, xml_text ), collapse = ";")
  js <- paste0("function zzz(){", js, "};")
  xml_remove(scr)
  xml_attr(data, "width") <- NULL
  xml_attr(data, "height") <- NULL
  unlink(path)

  tooltip_set <- opts_tooltip()
  hover_set <- opts_hover()
  zoom_set <- opts_zoom()
  selection_set <- opts_selection()
  toolbar_set <- opts_toolbar()
  shiny_sizing_set <- opts_shiny_sizing()

  x = list( html = as.character(data), js = js,
            uid = canvas_id, width = width,
            ratio = width_svg / height_svg,
            settings = list(
              tooltip = tooltip_set,
              hover = hover_set,
              zoom = zoom_set,
              capture = selection_set,
              toolbar = toolbar_set,
              shiny_sizing = shiny_sizing_set
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
#' @description Makes a reactive version of girafe
#' object for use in Shiny.
#'
#' @param expr An expression that returns a \code{\link{girafe}} object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @export
renderGirafe <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, girafeOutput, env, quoted = TRUE)
}

