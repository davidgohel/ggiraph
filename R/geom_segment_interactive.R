#' @title add segments with tooltips or click actions or double click actions 
#' 
#' @description 
#' Tooltips can be displayed when mouse is over segments, on click actions and 
#' double click actions can be set with javascript instructions.
#'
#' @seealso
#'  \code{\link{geom_path_interactive}}, \code{\link{geom_point_interactive}}
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
	ggplot2::layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractiveSegment,
			position = position,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			geom_params = list(
					arrow = arrow,
					lineend = lineend,
					na.rm = na.rm
			),
			params = list(...)
	)
}

#' @importFrom ggplot2 remove_missing
GeomInteractiveSegment <- ggproto("GeomInteractiveSegment", Geom,
		draw = function(data, scales, coordinates, arrow = NULL,
				lineend = "butt", na.rm = FALSE, ...) {
			
			inter.vars = intersect(c("tooltips", "clicks", "id"), names(data))
			
			data <- remove_missing(data, na.rm, c("x", "y", "xend", "yend", "linetype", "size", "shape", inter.vars) )

			if (nrow(data) < 1 || ncol(data) < 1 ) return(zeroGrob())
			
			if (coordinates$is_linear()) {
				coord <- coordinates$transform(data, scales)
				return(interactiveSegmentsGrob(coord$x, coord$y, coord$xend, coord$yend,
								tooltips = coord$tooltips,
								clicks = coord$clicks,
								id = coord$id,
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
			ends <- plyr::rename(subset(data, select = c(-x, -y)), c("xend" = "x", "yend" = "y"),
					warn_missing = FALSE)
			
			pieces <- rbind(starts, ends)
			pieces <- pieces[order(pieces$group),]
			GeomPathInteractive$draw_groups(pieces, scales, coordinates, arrow = arrow, ...)
		},
		
		required_aes = c("x", "y", "xend", "yend"),
		default_aes = aes(colour = "black", size = 0.5, linetype = 1, alpha = NA),
		
		draw_key = draw_key_path
)
