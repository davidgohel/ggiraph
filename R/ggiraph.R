#' @import htmlwidgets
#' @import htmltools
#' @import rvg
#' @import grid
#' @importFrom grDevices dev.off
#' @importFrom xml2 read_xml
#' @importFrom xml2 xml_find_all
#' @importFrom xml2 xml_text
#' @importFrom xml2 xml_ns

#' @title ggiraph
#'
#' @description Create an interactive graphic
#' to be used in a web browser.
#'
#' @param fun plot function. The function will be executed to produce graphics.
#' For \code{lattice} or \code{ggplot} object, the function should be \code{print}
#' and at least an extra argument \code{x} should specify the object
#' to plot. For traditionnal plots, the function should contain plot instructions. See examples.
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param width widget width
#' @param height widget height
#' @param hover_css css to apply when mouse is hover and element with a data-id attribute
#' @param ... arguments for \code{fun}.
#' @seealso \code{\link{geom_path_interactive}},
#' \code{\link{geom_point_interactive}},
#' \code{\link{geom_polygon_interactive}},
#' \code{\link{geom_rect_interactive}},
#' \code{\link{geom_segment_interactive}}
#' @examples
#' # ggiraph simple example -------
#' @example examples/geom_point_interactive.R
#' @export
ggiraph <- function(fun,
	pointsize = 12, width = 6, height = 6, hover_css = "{fill:orange;}", ...) {

	ggiwid.options = getOption("ggiwid")
	tmpdir = tempdir()
	path = tempfile()
	canvas_id <- ggiwid.options$svgid
	dsvg(file = path, pointsize = pointsize, standalone = TRUE,
			width = width, height = height,
			canvas_id = canvas_id
		)
	fun(...)
	dev.off()

	ggiwid.options$svgid = 1 + ggiwid.options$svgid
	options("ggiwid"=ggiwid.options)

	svg_container <- paste( scan(path, what = "character", sep = "\n", quiet = TRUE), collapse = "")

	data <- read_xml( path )
	scr <- xml_find_all(data, "//*[@type='text/javascript']", ns = xml_ns(data) )
	js <- paste( sapply( scr, xml_text ), collapse = ";")

	unlink(path)

	data_id_class <- basename(tempfile(tmpdir = "", fileext = "", pattern = "cl"))

	x = list( html = HTML( svg_container ), code = js, canvas_id = ggiwid.options$svgid,
	          data_id_class = data_id_class, hover_css = hover_css)

	# create widget
	htmlwidgets::createWidget(
			name = 'ggiraph',
			x,
			width = width*72,
			height = height*72,
			package = 'ggiraph',
			sizingPolicy = sizingPolicy(padding = 0, browser.fill = TRUE)
	)
}

#' @title Create a ggiraph output element
#' @description Render a ggiraph within an application page.
#'
#' @param outputId output variable to read the ggiraph from.
#' @examples
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' @export
ggiraphOutput <- function(outputId){
	shinyWidgetOutput(outputId, 'ggiraph', package = 'ggiraph', width = "100%",height = "100%")
}

#' @title Reactive version of ggiraph object
#'
#' @description Makes a reactive version of a ggiraph object for use in Shiny.
#'
#' @param expr An expression that returns a \code{\link{ggiraph}} object.
#' @param env The environment in which to evaluate expr.
#' @param quoted Is \code{expr} a quoted expression
#' @examples
#' if( require(shiny) && interactive() ){
#'   app_dir <- file.path( system.file(package = "ggiraph"), "shiny" )
#'   shinyAppDir(appDir = app_dir )
#' }
#' @export
renderggiraph <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, ggiraphOutput, env, quoted = TRUE)
}
