#' ggiraph
#'
#' <Add Description>
#'
#' @param fun fun
#' @param pointsize default to 12
#' @param graph.width gra w
#' @param graph.height graph h
#' @param fontname fn
#' @param width w 
#' @param height h
#' @param ... sddf sf
#' @import htmlwidgets
#' @import htmltools
#' @import rvg
#' @import grid
#' @importFrom xml2 read_xml
#' @importFrom xml2 xml_find_all
#' @importFrom xml2 xml_text
#' @export
ggiraph <- function(fun, pointsize=12, 
		graph.width=504, graph.height=504, fontname = "Verdana", 
		width = NULL, height = NULL, ...) {
	
	ggiwid.options = getOption("ggiwid")
	tmpdir = tempdir()
	base_name = tempfile(tmpdir = "", fileext = "", pattern = "")
	
	rvg(rootname = file.path(tmpdir, base_name), 
			ps = pointsize, 
			width = graph.width, height = graph.height, 
			fontname = fontname, 
			plot_id = ggiwid.options$id
	)
	fun(...)
	dev.off()
	file.l = list.files(path = tmpdir, pattern = "\\.svg$", full.names = TRUE )
	
	ggiwid.options$id = length(file.l) + ggiwid.options$id
	options("ggiwid"=ggiwid.options)
	
	svg_containers = sapply(file.l, 
			function(x) 
				paste( scan(x, what = "character", sep = "\n"), collapse = "\n") 
	)
	js = sapply( svg_containers, function(x){
		data <- read_xml( x )
		scr = xml_find_all(data, ".//script")
		paste( sapply( scr, xml_text ), collapse = "\n")
	})

	unlink(file.l)
	x = list(
			html = HTML(paste(svg_containers, collapse = "\n")), 
			js = paste(js, collapse = "\n")
	)
	
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
