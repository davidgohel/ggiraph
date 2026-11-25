#' @rdname geom_crossbar_interactive
#' @export
geom_linerange_interactive <- function(...) {
  layer_interactive(geom_linerange, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveLinerange <- ggproto(
  "GeomInteractiveLinerange",
  GeomLinerange,
  default_aes = add_default_interactive_aes(GeomLinerange),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    gr <- GeomLinerange$draw_panel(data, panel_params, coord, ...)
    add_interactive_attrs(gr, segment_drawn_data(data), ipar = .ipar, by_shape = TRUE)
  }
)
