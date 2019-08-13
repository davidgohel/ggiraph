#' @rdname geom_rect_interactive
#' @export
#' @examples
#' # add interactive tiles to a ggplot -------
#' @example examples/geom_tile_interactive.R
geom_tile_interactive <- function(mapping = NULL, data = NULL,
		stat = "identity", position = "identity",
		...,
		na.rm = FALSE,
		show.legend = NA,
		inherit.aes = TRUE) {
	layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractiveTile,
			position = position,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			params = list(
					na.rm = na.rm,
					...
			)
	)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveTile <- ggproto(
		"GeomInteractiveTile", GeomInteractiveRect,
		extra_params = c("na.rm"),
		
		setup_data = function(data, params) {
			data$width <- data$width %||% params$width %||% resolution(data$x, FALSE)
			data$height <- data$height %||% params$height %||% resolution(data$y, FALSE)
			
			transform(data,
					xmin = x - width / 2,  xmax = x + width / 2,  width = NULL,
					ymin = y - height / 2, ymax = y + height / 2, height = NULL
			)
		},
		
		default_aes = aes(fill = "grey20", colour = NA, size = 0.1, linetype = 1,
				alpha = NA, width = NA, height = NA,
				tooltip = NULL, onclick = NULL, data_id = NULL),
		
		required_aes = c("x", "y"),
		
		draw_key = draw_key_polygon
)
