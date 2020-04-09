#' @export
#' @rdname geom_bar_interactive
geom_col_interactive <- function(...)
  layer_interactive(geom_col, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveCol <- ggproto(
  "GeomInteractiveCol",
  GeomCol,
  default_aes = add_default_interactive_aes(GeomCol),
  draw_key = function(data, params, size) {
    gr <- GeomCol$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(self, data, panel_params, coord, width = NULL, flipped_aes = FALSE) {
    GeomInteractiveRect$draw_panel(data, panel_params, coord)
  }
)
