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
  draw_panel = function(
    data,
    panel_params,
    coord,
    fatten = 4,
    flipped_aes = FALSE,
    na.rm = FALSE,
    .ipar = IPAR_NAMES
  ) {
    if (is.null(data[[flipped_names(flipped_aes)$y]])) {
      return(
        GeomInteractiveLinerange$draw_panel(
          data,
          panel_params,
          coord,
          flipped_aes = flipped_aes,
          na.rm = na.rm,
          .ipar = .ipar
        )
      )
    }

    ggname(
      "geom_pointrange",
      gTree(
        children = gList(
          GeomInteractiveLinerange$draw_panel(
            data,
            panel_params,
            coord,
            flipped_aes = flipped_aes,
            na.rm = na.rm,
            .ipar = .ipar
          ),
          GeomInteractivePoint$draw_panel(
            transform(data, size = size * fatten),
            panel_params,
            coord,
            na.rm = na.rm,
            .ipar = .ipar
          )
        )
      )
    )
  }
)
