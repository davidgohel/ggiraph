#' @title Line interactive segments
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_segment}}.
#' See the documentation for those functions for more details.
#'
#' @seealso \code{\link{girafe}}
#' @inheritParams geom_point_interactive
#' @param lineend Line end style (round, butt, square)
#' @param arrow Arrow specification, as created by ?grid::arrow
#' @examples
#' # add interactive segments to a ggplot -------
#' @example examples/geom_segment_interactive.R
#' @export
geom_segment_interactive <- function(mapping = NULL, data = NULL, stat = "identity",
		position = "identity", arrow = NULL, lineend = "butt",
		na.rm = FALSE, show.legend = NA, inherit.aes = TRUE,
		...) {
	layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractiveSegment,
			position = position,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			params = list(
					arrow = arrow,
					lineend = lineend,
					na.rm = na.rm,
					...
			)
	)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveSegment <- ggproto("GeomSegment", Geom,
		draw_panel = function(data, panel_scales, coord, arrow = NULL,
				lineend = "butt", na.rm = FALSE) {

			data <- remove_missing(data, na.rm = na.rm,
					c("x", "y", "xend", "yend", "linetype", "size", "shape", "tooltip", "onclick", "data_id"),
					name = "geom_segment_interactive")
			if (nrow(data) < 1 || ncol(data) < 1 ) return(zeroGrob())

			if (coord$is_linear()) {
				coord <- coord$transform(data, panel_scales)
				if( !is.null(coord$tooltip) && !is.character(coord$tooltip) )
				  coord$tooltip <- as.character(coord$tooltip)
				if( !is.null(coord$onclick) && !is.character(coord$onclick) )
				  coord$onclick <- as.character(coord$onclick)
				if( !is.null(coord$data_id) && !is.character(coord$data_id) )
				  coord$data_id <- as.character(coord$data_id)


				return(interactive_segments_grob(coord$x, coord$y, coord$xend, coord$yend,
								tooltip = coord$tooltip,
								onclick = coord$onclick,
								data_id = coord$data_id,
								default.units = "native",
								gp = gpar(
										col = alpha(coord$colour, coord$alpha),
										fill = alpha(coord$colour, coord$alpha),
										lwd = coord$size * .pt,
										lty = coord$linetype,
										lineend = lineend
								),
								arrow = arrow
						))
			}

			data$group <- 1:nrow(data)
			starts <- subset(data, select = c(-xend, -yend))

			ends <- subset(data, select = c(-x, -y))
			names(ends)[names(ends) %in% "xend"] <- "x"
			names(ends)[names(ends) %in% "yend"] <- "y"

			pieces <- rbind(starts, ends)
			pieces <- pieces[order(pieces$group),]

			GeomPathInteractive$draw_panel(pieces, panel_scales, coord, arrow = arrow,
					lineend = lineend)
		},

		required_aes = c("x", "y", "xend", "yend"),
		default_aes = aes(colour = "black", size = 0.5, linetype = 1, alpha = NA,
		                  tooltip = NULL, onclick = NULL, data_id = NULL),

		draw_key = draw_key_path
)

