#' @import htmlwidgets
#' @import htmltools
#' @import rvg
#' @import grid
#' @importFrom xml2 read_xml
#' @importFrom xml2 xml_find_all
#' @importFrom xml2 xml_text

#' @title ggiraph
#'
#' @description Create an interactive graphic
#' to be used in a web browser.
#'
#' @param fun plot function. The function will be executed to produce graphics.
#' For \code{lattice} or \code{ggplot} object, the function should be \code{print}
#' and at least an extra argument \code{x} should specify the object
#' to plot. For traditionnal plots, the function should contain plot instructions. See examples.
#' @param graph.width plot width in pixels (default value is 504).
#' @param graph.height plot height in pixels (default value is 504).
#' @param pointsize the default pointsize of plotted text in pixels, default to 12.
#' @param fontname the default font family to use, default to "Verdana".
#' @param width widget width
#' @param height widget height
#' @param ... arguments for \code{fun}.
#' @export
ggiraph <- function(fun, graph.width=504, graph.height=504,
	pointsize = 12, fontname = "Verdana", width = NULL, height = NULL, ...) {

	ggiwid.options = getOption("ggiwid")
	tmpdir = tempdir()
	base_name = tempfile(tmpdir = "", fileext = "", pattern = "")

	rvg(rootname = file.path(tmpdir, base_name),
			ps = pointsize,
			width = graph.width, height = graph.height,
			fontname = fontname,
			plot_id = ggiwid.options$svgid
	)
	fun(...)
	dev.off()
	file.l = list.files(path = tmpdir, pattern = "\\.svg$", full.names = TRUE )

	ggiwid.options$svgid = length(file.l) + ggiwid.options$svgid
	options("ggiwid"=ggiwid.options)

	svg_containers = lapply(file.l,
			function(x)
				paste( scan(x, what = "character", sep = "\n", quiet = TRUE), collapse = "")
	)
	js = lapply( svg_containers, function(x){
		data <- read_xml( x )
		scr = xml_find_all(data, ".//script")
		paste( sapply( scr, xml_text ), collapse = "\n")
	})
	
	unlink(file.l)
	
	svg_containers = lapply( svg_containers, HTML )
	names(svg_containers) = NULL#basename( names(svg_containers) )
	names(js) = NULL#basename( names(js) )
	
	x = list( html = svg_containers, code = js, length = length(svg_containers) )

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
