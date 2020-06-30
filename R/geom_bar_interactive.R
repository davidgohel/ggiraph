#' @title Create interactive bars
#'
#' @description
#' The geometries are based on [geom_bar()]
#' and [geom_col()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive bar -------
#' @example examples/geom_bar_interactive.R
#' @seealso [girafe()]
#' @export
geom_bar_interactive <- function(...)
  layer_interactive(geom_bar, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @include geom_rect_interactive.R
GeomInteractiveBar <- ggproto(
  "GeomInteractiveBar",
  GeomBar,
  default_aes = add_default_interactive_aes(GeomBar),
  draw_key = function(data, params, size) {
    gr <- GeomBar$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(self, data, panel_params, coord, width = NULL, flipped_aes = FALSE) {
    GeomInteractiveRect$draw_panel(data, panel_params, coord)
  }
)
