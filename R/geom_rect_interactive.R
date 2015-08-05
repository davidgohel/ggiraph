#' @title add rectangles with tooltips or click actions or double click actions 
#' 
#' @description 
#' Tooltips can be displayed when mouse is over rectangles, on click actions and 
#' double click actions can be set with javascript instructions.
#'
#' @seealso
#'  \code{\link{geom_path_interactive}}, \code{\link{geom_point_interactive}}
#' @inheritParams geom_point_interactive
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_rect_interactive.R
#' @export 
geom_rect_interactive <- function(mapping = NULL, data = NULL, stat = "identity",
		position = "identity", show.legend = NA,
		inherit.aes = TRUE, ...) {
	ggplot2::layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractiveRect,
			position = position,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			params = list(...)
	)
}

GeomInteractiveRect <- ggproto("GeomInteractiveRect", Geom,
		default_aes = aes(colour = NA, fill = "grey20", size = 0.5, linetype = 1,
				alpha = NA),
		
		required_aes = c("xmin", "xmax", "ymin", "ymax"),
		
		draw = function(self, data, scales, coordinates, ...) {
			if (!coordinates$is_linear()) {
				aesthetics <- setdiff(
						names(data), c("x", "y", "xmin", "xmax", "ymin", "ymax")
				)
				
				polys <- plyr::alply(data, 1, function(row) {
							poly <- rect_to_poly(row$xmin, row$xmax, row$ymin, row$ymax)
							aes <- as.data.frame(row[aesthetics],
									stringsAsFactors = FALSE)[rep(1,5), ]
							
							GeomInteractivePolygon$draw(cbind(poly, aes), scales, coordinates)
						})
				
				setGrobName("bar", do.call("grobTree", polys))
			} else {
				coords <- coordinates$transform(data, scales)
				setGrobName("geom_rect_interactive", interactiveRectGrob(
								coords$xmin, coords$ymax,
								width = coords$xmax - coords$xmin,
								height = coords$ymax - coords$ymin,
								tooltips = coords$tooltips,
								clicks = coords$clicks,
								dbclicks = coords$dbclicks,
								default.units = "native",
								just = c("left", "top"),
								gp = gpar(
									col = coords$colour,
									fill = alpha(coords$fill, coords$alpha),
									lwd = coords$size * .pt,
									lty = coords$linetype,
									lineend = "butt"
								)
						))
			}
		},
		
		draw_groups = function(self, ...) self$draw(...),
		
		draw_key = draw_key_polygon
)


