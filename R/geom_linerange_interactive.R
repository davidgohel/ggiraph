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
  draw_panel = function(
    data,
    panel_params,
    coord,
    flipped_aes = FALSE,
    lineend = "butt",
    linejoin = "round",
    na.rm = FALSE,
    .ipar = IPAR_NAMES
  ) {
    data <- flip_data(data, flipped_aes)
    data <- transform(data, xend = x, y = ymin, yend = ymax)
    data <- flip_data(data, flipped_aes)
    ggname(
      "geom_linerange_interactive",
      GeomInteractiveSegment$draw_panel(
        data,
        panel_params,
        coord,
        na.rm = na.rm,
        lineend = lineend,
        linejoin = linejoin,
        .ipar = .ipar
      )
    )
  }
)
