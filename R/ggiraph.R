#' @import htmlwidgets
#' @import htmltools
#' @import rvg
#' @import grid
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
#' @param graph.width plot width in inches (default value is 7).
#' @param graph.height plot height in inches (default value is 7).
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param width widget width
#' @param height widget height
#' @param ... arguments for \code{fun}.
#' @examples
#' # ggiraph simple example -------
#' @example examples/ggiraph.R
#' @export
ggiraph <- function(fun, graph.width=7, graph.height=7,
	pointsize = 12, width = NULL, height = NULL, ...) {

	ggiwid.options = getOption("ggiwid")
	tmpdir = tempdir()
	base_name = tempfile(tmpdir = "", fileext = "", pattern = "")
	path = tempfile()
	dsvg(file = path, pointsize = pointsize, standalone = TRUE,
			width = graph.width, height = graph.height,
			canvas_id = ggiwid.options$svgid
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
	x = list( html = HTML( svg_container ), code = js )

	# create widget
	htmlwidgets::createWidget(
			name = 'ggiraph',
			x,
			width = width,
			height = height,
			package = 'ggiraph'
	)
}

#' Widget output function for use in Shiny
#'
#' @param outputId outputId
#' @export
ggiraphOutput <- function(outputId){
	shinyWidgetOutput(outputId, 'ggiraph', package = 'ggiraph')
}

#' Widget render function for use in Shiny
#'
#' @param expr expr
#' @param env env
#' @param quoted quoted
#' @export
renderggiraph <- function(expr, env = parent.frame(), quoted = FALSE) {
	if (!quoted) { expr <- substitute(expr) } # force quoted
	shinyRenderWidget(expr, ggiraphOutput, env, quoted = TRUE)
}
