#' @rdname geom_abline_interactive
#' @examples
#' # add vertical interactive reference lines to a ggplot -------
#' @example examples/geom_vline_interactive.R
#' @seealso [girafe()]
#' @export
geom_vline_interactive <- function(...) {
  layer_interactive(geom_vline, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveVline <- ggproto(
  "GeomInteractiveVline",
  GeomVline,
  default_aes = add_default_interactive_aes(GeomVline),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    gr <- GeomVline$draw_panel(data, panel_params, coord, ...)
    # 'ggplot2' draws the unique rows; the computed ends depend on the
    # other columns, so the unique rows are the same before computing them
    add_interactive_attrs(gr, segment_drawn_data(unique0(data)), ipar = .ipar, by_shape = TRUE)
  }
)
