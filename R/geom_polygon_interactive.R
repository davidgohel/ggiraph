#' @title add polygons with tooltips or click actions or double click actions
#'
#' @description
#' tooltips can be displayed when mouse is over polygons, on click actions and
#' double click actions can be set with javascript instructions.
#'
#' @seealso \code{\link{ggiraph}}
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

		default_aes = aes(colour = "NA", fill = "grey20", size = 0.5, linetype = 1,
				alpha = NA),

		required_aes = c("x", "y"),

		draw_key = draw_key_polygon
)



#' @importFrom ggplot2 PositionIdentity
#' @title interactive polygons from a reference map.
#'
#' @description
#' tooltips can be displayed when mouse is over segments, on click actions and
#' double click actions can be set with javascript instructions.
#'
#' @param map Data frame that contains the map coordinates. See \code{\link[ggplot2]{geom_map}}.
#' @inheritParams geom_point_interactive
#' @examples
#' # add interactive maps to a ggplot -------
#' @example examples/geom_map_interactive.R
#' @seealso \code{\link{ggiraph}}
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
