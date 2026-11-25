#' @title Create interactive polygons
#'
#' @description
#' The geometry is based on [ggplot2::geom_polygon()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_polygon_interactive.R
#' @seealso [girafe()]
#' @export
geom_polygon_interactive <- function(...) {
  layer_interactive(geom_polygon, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @include geom_path_interactive.R
GeomInteractivePolygon <- ggproto(
  "GeomInteractivePolygon",
  GeomPolygon,
  default_aes = add_default_interactive_aes(GeomPolygon),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    # a polygon (or a path with holes) with one shape per group
    gr <- GeomPolygon$draw_panel(data, panel_params, coord, ...)
    add_interactive_attrs(gr, polygon_group_data(data), ipar = .ipar, by_shape = TRUE)
  }
)

#' One data row per group, as the shapes drawn by `GeomPolygon$draw_panel()`
#' @details
#' 'ggplot2' draws one shape per group, sorted by group, with the
#' graphical parameters of the first row of each group: each shape takes
#' the interactive parameters of that row.
#' @noRd
polygon_group_data <- function(data) {
  data <- data[order(data$group), , drop = FALSE]
  data[!duplicated(data$group), , drop = FALSE]
}
