#' @title interactive polygons
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_polygon}}.
#' See the documentation for those functions for more details.
#'
#' @seealso \code{\link{girafe}}
#' @inheritParams geom_point_interactive
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_polygon_interactive.R
#' @export
geom_polygon_interactive <- function(mapping = NULL, data = NULL, stat = "identity",
		position = "identity", na.rm = FALSE, show.legend = NA,
		inherit.aes = TRUE, ...) {
	layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractivePolygon,
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
#' @include geom_path_interactive.R
GeomInteractivePolygon <- ggproto("GeomInteractivePolygon", Geom,
		draw_panel = function(data, panel_scales, coord) {
			n <- nrow(data)
			if (n == 1) return(zeroGrob())

			munched <- coord_munch(coord, data, panel_scales)
			# Sort by group to make sure that colors, fill, etc. come in same order
			munched <- munched[order(munched$group), ]

			# For gpar(), there is one entry per polygon (not one entry per point).
			# We'll pull the first value from each group, and assume all these values
			# are the same within each group.
			first_idx <- !duplicated(munched$group)
			first_rows <- munched[first_idx, ]

			if( !is.null(munched$tooltip) && !is.character(munched$tooltip) )
			  munched$tooltip <- as.character(munched$tooltip)
			if( !is.null(munched$onclick) && !is.character(munched$onclick) )
			  munched$onclick <- as.character(munched$onclick)
			if( !is.null(munched$data_id) && !is.character(munched$data_id) )
			  munched$data_id <- as.character(munched$data_id)

			setGrobName(
			  "geom_polygon_interactive",
			  interactive_polygon_grob(
			    munched$x,
			    munched$y,
			    default.units = "native",
			    id = munched$group,
			    tooltip = munched$tooltip,
			    onclick = munched$onclick,
			    data_id = munched$data_id,
			    gp = gpar(
			      col = first_rows$colour,
			      fill = alpha(first_rows$fill, first_rows$alpha),
			      lwd = first_rows$size * .pt,
			      lty = first_rows$linetype
			    )
			  )
			)
		},

		default_aes = aes(
		  colour = "NA", fill = "grey20",
      size = 0.5, linetype = 1, alpha = NA,
    	tooltip = NULL, onclick = NULL, data_id = NULL),

		required_aes = c("x", "y"),

		draw_key = draw_key_polygon
)
