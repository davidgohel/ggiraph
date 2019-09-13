#' @rdname geom_rect_interactive
#' @export
#' @examples
#' # add interactive tiles to a ggplot -------
#' @example examples/geom_tile_interactive.R
geom_tile_interactive <- function(...)
  layer_interactive(geom_tile, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveTile <- ggproto(
  "GeomInteractiveTile",
  GeomTile,
  default_aes = add_default_interactive_aes(GeomTile),
  draw_key = function(data, params, size) {
    gr <- GeomTile$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(self, data, panel_params, coord, linejoin = "mitre") {
    GeomInteractiveRect$draw_panel(data, panel_params, coord, linejoin = linejoin)
  }
)
