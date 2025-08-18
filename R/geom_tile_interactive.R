#' @rdname geom_rect_interactive
#' @export
#' @examples
#' # add interactive tiles to a ggplot -------
#' @example examples/geom_tile_interactive.R
geom_tile_interactive <- function(...) {
  layer_interactive(geom_tile, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveTile <- ggproto(
  "GeomInteractiveTile",
  GeomTile,
  default_aes = add_default_interactive_aes(GeomTile),
  non_missing_aes = c("xmin", "xmax", "ymin", "ymax"),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    lineend = "butt",
    linejoin = "mitre",
    ...,
    .ipar = IPAR_NAMES
  ) {
    GeomInteractiveRect$draw_panel(
      data,
      panel_params,
      coord,
      lineend = lineend,
      linejoin = linejoin,
      ...,
      .ipar = .ipar
    )
  }
)
