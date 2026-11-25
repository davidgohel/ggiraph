#' @title Create interactive line segments and curves
#'
#' @description
#' The geometries are based on [ggplot2::geom_segment()] and [ggplot2::geom_curve()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive segments and curves to a ggplot -------
#' @example examples/geom_segment_interactive.R
#' @seealso [girafe()]
#' @export
geom_segment_interactive <- function(...) {
  layer_interactive(geom_segment, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveSegment <- ggproto(
  "GeomInteractiveSegment",
  GeomSegment,
  default_aes = add_default_interactive_aes(GeomSegment),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    # segments, or a polyline (one line per segment) in non linear coordinates
    gr <- GeomSegment$draw_panel(data, panel_params, coord, ...)
    add_interactive_attrs(gr, segment_drawn_data(data), ipar = .ipar, by_shape = TRUE)
  }
)
