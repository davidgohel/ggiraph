#' @title Create interactive polygons from a reference map
#'
#' @description
#' The geometry is based on [ggplot2::geom_map()].
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
geom_map_interactive <- function(...) {
  layer_interactive(geom_map, ...)
}

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
  draw_panel = function(data, panel_params, coord, ..., map, .ipar = IPAR_NAMES) {
    gr <- GeomMap$draw_panel(data, panel_params, coord, ..., map = map)
    add_interactive_attrs(gr, map_group_data(data, map), ipar = .ipar, by_shape = TRUE)
  }
)

#' One data row per shape drawn by `GeomMap$draw_panel()`
#' @details
#' 'ggplot2' keeps the regions found in both the data and the map, draws one
#' shape per group of the map (a region can have several), in the order of
#' the map, and gives each shape the data row of its region (`map_id`).
#' @noRd
map_group_data <- function(data, map) {
  common <- intersect(data$map_id, map$id)
  data <- data[data$map_id %in% common, , drop = FALSE]
  map <- map[map$id %in% common, , drop = FALSE]
  group <- map$group %||% map$id
  first <- !duplicated(match(group, unique0(group)))
  data[match(map$id[first], data$map_id), , drop = FALSE]
}
