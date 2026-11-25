#' @rdname geom_crossbar_interactive
#' @export
geom_errorbar_interactive <- function(...) {
  layer_interactive(geom_errorbar, ...)
}


#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveErrorbar <- ggproto(
  "GeomInteractiveErrorbar",
  GeomErrorbar,
  default_aes = add_default_interactive_aes(GeomErrorbar),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(self, data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    # one polyline per errorbar: each errorbar is a line of the polyline
    gr <- GeomErrorbar$draw_panel(data, panel_params, coord, ...)
    add_interactive_attrs(gr, data, ipar = .ipar, by_shape = TRUE)
  }
)
