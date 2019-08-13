#' @title interactive polygons from a reference map.
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_map}}.
#' See the documentation for those functions for more details.
#'
#' @param map Data frame that contains the map coordinates. See \code{\link[ggplot2]{geom_map}}.
#' @inheritParams geom_point_interactive
#' @examples
#' # add interactive maps to a ggplot -------
#' @example examples/geom_map_interactive.R
#' @seealso \code{\link{girafe}}
#' @export
geom_map_interactive <- function(mapping = NULL, data = NULL, map, stat = "identity",
		na.rm = FALSE, show.legend = NA, inherit.aes = TRUE, ...) {
	# Get map input into correct form
	stopifnot(is.data.frame(map))
	if (!is.null(map$lat)) map$y <- map$lat
	if (!is.null(map$long)) map$x <- map$long
	if (!is.null(map$region)) map$id <- map$region
	stopifnot(all(c("x", "y", "id") %in% names(map)))
	layer(
			data = data,
			mapping = mapping,
			stat = stat,
			geom = GeomInteractiveMap,
			position = PositionIdentity,
			show.legend = show.legend,
			inherit.aes = inherit.aes,
			params = list(
					map = map,
					na.rm = na.rm,
					...
			)
	)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveMap <- ggproto(
		"GeomInteractiveMap",
		GeomInteractivePolygon,
		draw_panel = function(data, panel_scales, coord, map) {
			# Only use matching data and map ids
			common <- intersect(data$map_id, map$id)
			data <- data[data$map_id %in% common, , drop = FALSE]
			map <- map[map$id %in% common, , drop = FALSE]
			
			# Munch, then set up id variable for polygonGrob -
			# must be sequential integers
			coords <- coord_munch(coord, map, panel_scales)
			if (!is.null(coords$group))
				coords$group <- coords$group
			else
				coords$group <- coords$id
			grob_id <- match(coords$group, unique(coords$group))
			
			# Align data with map
			data_rows <- match(coords$id[!duplicated(grob_id)], data$map_id)
			data <- data[data_rows, , drop = FALSE]
			run_l <- rle(grob_id)
			
			args <- list( x = coords$x, y = coords$y,
					default.units = "native", id = grob_id,
					gp = gpar(
							col = data$colour,
							fill = alpha(data$fill, data$alpha),
							lwd = data$size * .pt
					)
			)
			
			# TODO: tidy this.
			if( !is.null(data$tooltip) && !is.character(data$tooltip) )
				data$tooltip <- as.character(data$tooltip)
			if( !is.null(data$onclick) && !is.character(data$onclick) )
				data$onclick <- as.character(data$onclick)
			if( !is.null(data$data_id) && !is.character(data$data_id) )
				data$data_id <- as.character(data$data_id)
			
			if (!is.null(data$tooltip))
				args$tooltip <- unlist(mapply(rep, data$tooltip, run_l$lengths))
			if (!is.null(data$onclick))
				args$onclick <- unlist(mapply(rep, data$onclick, run_l$lengths))
			if (!is.null(data$data_id))
				args$data_id <- unlist(mapply(rep, data$data_id, run_l$lengths))
			
			
			do.call(interactive_polygon_grob, args)
		},
		
		required_aes = c("map_id")
)
