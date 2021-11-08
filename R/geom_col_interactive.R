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
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(self, data, panel_params, coord, 
                        width = NULL, flipped_aes = FALSE, 
                        .ipar = IPAR_NAMES) {
    GeomInteractiveRect$draw_panel(data, panel_params, coord, .ipar = .ipar)
  }
)
