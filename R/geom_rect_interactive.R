#' @title Create interactive rectangles
#'
#' @description
#' These geometries are based on [ggplot2::geom_rect()] and [ggplot2::geom_tile()].
#' See the documentation for those functions for more details.
#'
#' @note
#' Converting a raster to svg elements could inflate dramatically the size of the
#' svg and make it unreadable in a browser.
#' Function `geom_tile_interactive` should be used with caution, total number of
#' rectangles should be small.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_rect_interactive.R
#' @seealso [girafe()]
#' @export
geom_rect_interactive <- function(...) {
  layer_interactive(geom_rect, ...)
}

#' @importFrom vctrs vec_cbind
#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @include geom_polygon_interactive.R
GeomInteractiveRect <- ggproto(
  "GeomInteractiveRect",
  GeomRect,
  default_aes = add_default_interactive_aes(GeomRect),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(self, data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    # rectangles, or a polygon (one shape per rectangle) in non linear
    # coordinates: one data row per rectangle
    gr <- GeomRect$draw_panel(data, panel_params, coord, ...)
    add_interactive_attrs(gr, data, ipar = .ipar, by_shape = TRUE)
  }
)
