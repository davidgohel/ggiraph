#' @title Create interactive bars
#'
#' @description
#' The geometries are based on [geom_bar()]
#' and [geom_col()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for interactive geom functions
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
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(self, data, panel_params, coord, 
                        width = NULL, flipped_aes = FALSE, 
                        .ipar = IPAR_NAMES) {
    GeomInteractiveRect$draw_panel(data, panel_params, coord, .ipar = .ipar)
  }
)
