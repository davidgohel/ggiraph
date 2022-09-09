#' @title Create interactive polygons from a reference map
#'
#' @description
#' The geometry is based on [geom_map()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive maps to a ggplot -------
#' @example examples/geom_map_interactive.R
#' @seealso [girafe()]
#' @export
geom_map_interactive <- function(...)
  layer_interactive(geom_map, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveMap <- ggproto(
  "GeomInteractiveMap",
  GeomMap,
  default_aes = add_default_interactive_aes(GeomMap),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, map, .ipar = IPAR_NAMES) {
    # Only use matching data and map ids
    common <- intersect(data$map_id, map$id)
    data <- data[data$map_id %in% common, , drop = FALSE]
    map <- map[map$id %in% common, , drop = FALSE]

    # Munch, then set up id variable for polygonGrob -
    # must be sequential integers
    coords <- coord_munch(coord, map, panel_params)
    coords$group <- coords$group %||% coords$id
    grob_id <- match(coords$group, unique(coords$group))

    # Align data with map
    data_rows <- match(coords$id[!duplicated(grob_id)], data$map_id)
    data <- data[data_rows, , drop = FALSE]

    gr <- polygonGrob(
      coords$x, coords$y, default.units = "native", id = grob_id,
      gp = gpar(
        col = data$colour, fill = alpha(data$fill, data$alpha),
        lwd = data$size * .pt
      )
    )

    run_l <- rle(grob_id)
    ip <- copy_interactive_attrs(data, list(), useList = TRUE, run_l$lengths, ipar = .ipar)
    add_interactive_attrs(gr, ip, ipar = .ipar)
  }
)
