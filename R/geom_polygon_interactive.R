#' @title add polygons with tooltips or click actions or double click actions 
#' 
#' @description 
#' Tooltips can be displayed when mouse is over polygons, on click actions and 
#' double click actions can be set with javascript instructions.
#'
#' @seealso
#'  \code{\link{geom_path_interactive}}, \code{\link{geom_point_interactive}}
#' @inheritParams geom_point_interactive
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_polygon_interactive.R
#' @export 
geom_polygon_interactive <- function(mapping = NULL, data = NULL, stat = "identity",
		position = "identity", show.legend = NA,
		inherit.aes = TRUE, ...) {
	ggplot2::layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractivePolygon,
			position = position,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			params = list(...)
	)
}

GeomInteractivePolygon <- ggproto("GeomInteractivePolygon", Geom,
		draw_groups = function(self, ...) self$draw(...),
		
		draw = function(self, data, scales, coordinates, ...) {
			n <- nrow(data)
			if (n == 1) return()
			
			# Check if group is numeric, to make polygonGrob happy (factors are numeric,
			# but is.numeric() will report FALSE because it actually checks something else)
			if (mode(data$group) != "numeric")
				data$group <- factor(data$group)
			inter.vars = intersect(c("tooltips", "clicks", "dbclicks"), names(data))
			
			munched <- coord_munch(coordinates, data, scales)
			# Sort by group to make sure that colors, fill, etc. come in same order
			munched <- munched[order(munched$group), ]
			
			# For gpar(), there is one entry per polygon (not one entry per point).
			# We'll pull the first value from each group, and assume all these values
			# are the same within each group.
			first_idx <- !duplicated(munched$group)
			first_rows <- munched[first_idx, ]

			setGrobName("geom_polygon_interactive", gTree(children = gList(
									interactivePolygonGrob(munched$x, munched$y, default.units = "native",
											id = munched$group,
											tooltips = munched$tooltips,
											clicks = munched$clicks,
											dbclicks = munched$dbclicks,
											gp = gpar(
													col = first_rows$colour,
													fill = alpha(first_rows$fill, first_rows$alpha),
													lwd = first_rows$size * ggplot2.pt,
													lty = first_rows$linetype
											)
									)
							)))
		},
		
		default_aes = aes(colour = "NA", fill = "grey20", size = 0.5, linetype = 1,
				alpha = NA),
		
		required_aes = c("x", "y"),
		
		draw_key = draw_key_polygon
)

