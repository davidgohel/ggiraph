#' @rdname geom_segment_interactive
#' @export
geom_curve_interactive <- function(...)
  layer_interactive(geom_curve, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveCurve <- ggproto(
  "GeomInteractiveCurve",
  GeomCurve,
  default_aes = add_default_interactive_aes(GeomCurve),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    zz <- GeomCurve$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    add_interactive_attrs(zz, coords, ipar = .ipar)
  }
)
