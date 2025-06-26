#' @title Create interactive line segments
#' parameterised by location, direction and distance
#'
#' @description
#' The geometry is based on [ggplot2::geom_spoke()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive line segments parameterised by location,
#' # direction and distance to a ggplot -------
#' @example examples/geom_spoke_interactive.R
#' @seealso [girafe()]
#' @export
geom_spoke_interactive <- function(...) {
  layer_interactive(geom_spoke, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveSpoke <- ggproto(
  "GeomInteractiveSpoke",
  GeomSpoke,
  default_aes = add_default_interactive_aes(GeomSpoke),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(..., .ipar = IPAR_NAMES) {
    GeomInteractiveSegment$draw_panel(..., .ipar = .ipar)
  }
)
