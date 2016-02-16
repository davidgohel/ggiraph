#' @title add points with tooltips or click actions or double click actions
#' for a scatterplot
#'
#' @description
#' The point_interactive geom is used to create interactive scatterplots, tooltips
#' can be displayed when mouse is over points, on click actions and double click actions can be
#' set with javascript instructions.
#'
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
#' @seealso \code{\link{ggiraph}}
#' @export
geom_point_interactive <- function(mapping = NULL, data = NULL, stat = "identity",
		position = "identity", na.rm = FALSE,
		show.legend = NA, inherit.aes = TRUE, ...) {
	layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractivePoint,
			position = position,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			params = list(
					na.rm = na.rm,
					...
			)
	)
}



#' @importFrom ggplot2 remove_missing
GeomInteractivePoint <- ggproto("GeomInteractivePoint", Geom,
		draw_panel = function(data, panel_scales, coord, na.rm = FALSE) {
			data <- remove_missing(data, na.rm, c("x", "y", "size", "shape", "tooltip", "onclick", "data_id"),
					name = "geom_point_interactive")
			if (nrow(data) < 1 || ncol(data) < 1 ) return(zeroGrob())

			coords <- coord$transform(data, panel_scales)

			if( !is.null(coords$tooltip) && !is.character(coords$tooltip) )
			  coords$tooltip <- as.character(coords$tooltip)
			if( !is.null(coords$onclick) && !is.character(coords$onclick) )
			  coords$onclick <- as.character(coords$onclick)
			if( !is.null(coords$data_id) && !is.character(coords$data_id) )
			  coords$data_id <- as.character(coords$data_id)

			setGrobName(
			  "geom_point_interactive",
			  interactive_points_grob(
			    coords$x,
			    coords$y,
			    tooltip = coords$tooltip,
			    onclick = coords$onclick,
			    data_id = coords$data_id,
			    pch = coords$shape,
			    gp = gpar(
			      col = alpha(coords$colour, coords$alpha),
			      fill = alpha(coords$fill, coords$alpha),
			      fontsize = coords$size * .pt + coords$stroke * .stroke / 2,
			      lwd = coords$stroke * .stroke / 2
			    )
			  )
			)
		},

		draw_key = draw_key_point,

		required_aes = c("x", "y"),
		non_missing_aes = c("size", "shape"),
		default_aes = aes(shape = 19, colour = "black", size = 1.5, fill = NA,
				alpha = NA, stroke = 0.5)
)

