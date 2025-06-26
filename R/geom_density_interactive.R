#' @title Create interactive smoothed density estimates
#'
#' @description
#' The geometry is based on [ggplot2::geom_density()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive bar -------
#' @example examples/geom_density_interactive.R
#' @seealso [girafe()]
#' @export
geom_density_interactive <- function(...) {
  layer_interactive(geom_density, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveDensity <- ggproto(
  "GeomInteractiveDensity",
  GeomDensity,
  default_aes = add_default_interactive_aes(GeomDensity),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(..., .ipar = IPAR_NAMES) {
    GeomInteractiveArea$draw_group(..., .ipar = .ipar)
  }
)
