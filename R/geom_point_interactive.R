#' @title add points with tooltips or click actions or double click actions 
#' for a scatterplot
#'
#' @description 
#' The point_interactive geom is used to create interactive scatterplots, tooltips 
#' can be displayed when mouse is over points, on click actions and double click actions can be 
#' set with javascript instructions.
#' 
#' @seealso \code{\link[ggplot2]{geom_point}}
#' @param mapping The aesthetic mapping, see \code{\link[ggplot2]{geom_point}}.
#' @param data A data frame, see \code{\link[ggplot2]{geom_point}}.
#' @param position Postion adjustment, see \code{\link[ggplot2]{geom_point}}.
#' @param stat The statistical transformation to use on the data for this
#'    layer, as a string, see \code{\link[ggplot2]{geom_point}}.
#' @param na.rm See \code{\link[ggplot2]{geom_point}}.
#' @param show.legend See \code{\link[ggplot2]{geom_point}}.
#' @param inherit.aes See \code{\link[ggplot2]{geom_point}}.
#' @param ... other arguments passed on to layer. See \code{\link[ggplot2]{geom_point}}.
#' @examples
#' # add interactive points to a ggplot -------
#' @example examples/geom_point_interactive.R
#' @export 
geom_point_interactive <- function(mapping = NULL, data = NULL, stat = "identity",
		position = "identity", na.rm = FALSE,
		show.legend = NA, inherit.aes = TRUE, ...) {
	ggplot2::layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractivePoint,
			position = position,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			geom_params = list(na.rm = na.rm),
			params = list(...)
	)
}


#' @importFrom ggplot2 remove_missing
GeomInteractivePoint <- ggproto("GeomPoint", Geom,
		draw = function(self, data, scales, coordinates, na.rm = FALSE, ...) {
			data <- remove_missing(data, na.rm, c("x", "y", "size", "shape", "tooltips", "clicks", "id"),
					name = "geom_point_interactive")
			if (nrow(data) < 1 || ncol(data) < 2 ) return(zeroGrob())
			coords <- coordinates$transform(data, scales)
			setGrobName("geom_point_interactive",
					interactivePointsGrob(
							coords$x, coords$y,
							pch = coords$shape,
							tooltips = coords$tooltips,
							clicks = coords$clicks,
							id = coords$id, 
							gp = gpar(
									col = alpha(coords$colour, coords$alpha),
									fill = alpha(coords$fill, coords$alpha),
									# Stroke is added around the outside of the point
									fontsize = coords$size * .pt + coords$stroke * .stroke / 2,
									lwd = coords$stroke * .stroke / 2
							)
					)
			)
		},
		
		draw_key = draw_key_point,
		
		required_aes = c("x", "y"),
		default_aes = aes(shape = 19, colour = "black", size = 1.5, fill = NA,
				alpha = NA, stroke = 0.5)
)




