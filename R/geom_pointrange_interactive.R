#' @rdname geom_crossbar_interactive
#' @export
geom_pointrange_interactive <- function(...) {
  layer_interactive(geom_pointrange, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractivePointrange <- ggproto(
  "GeomInteractivePointrange",
  GeomPointrange,
  default_aes = add_default_interactive_aes(GeomPointrange),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    gr <- GeomPointrange$draw_panel(data, panel_params, coord, ...)
    # without y, the linerange alone
    if (!inherits(gr, "gTree")) {
      return(add_interactive_attrs(
        gr,
        segment_drawn_data(data),
        ipar = .ipar,
      by_shape = TRUE
      ))
    }
    # the linerange, then the point
    gr$children[[1]] <- add_interactive_attrs(
      gr$children[[1]],
      segment_drawn_data(data),
      ipar = .ipar,
      by_shape = TRUE
    )
    gr$children[[2]] <- add_interactive_attrs(
      gr$children[[2]],
      data,
      ipar = .ipar,
      by_shape = TRUE
    )
    gr
  }
)
