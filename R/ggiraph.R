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
#' @import ReporteRs
#' @import grid
#' @export
ggiraph <- function(fun, pointsize=12, 
		graph.width=6, graph.height=6, fontname = "Verdana", 
		width = NULL, height = NULL, ...) {
	
	ggiwid.options = getOption("ggiwid")	
	
	plotelts = raphael.html(fun = fun, pointsize=pointsize, 
		width=graph.width, height=graph.height, fontname = fontname, 
		canvas_id = ggiwid.options$id, ... )
	ggiwid.options$id = length(plotelts$js.id) + ggiwid.options$id
	options("ggiwid"=ggiwid.options)
	x = list(
		html = HTML(plotelts$html),
		js = plotelts$js,
		divid = plotelts$div.id, 
		jsid = plotelts$js.id
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
