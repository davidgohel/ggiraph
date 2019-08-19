#' @title interactive bars
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_bar}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add interactive bar -------
#' @example examples/geom_bar_interactive.R
#' @seealso \code{\link{girafe}}
#' @export
geom_bar_interactive <- function(...) {
  layer_interactive(geom_bar, ...)
}

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
  draw_panel = function(self, data, panel_params, coord, width = NULL) {
    GeomInteractiveRect$draw_panel(data, panel_params, coord)
  }
)
