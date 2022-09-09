#' @title Create interactive points
#'
#' @description
#' The geometry is based on [geom_point()].
#' See the documentation for those functions for more details.
#'
#' @note
#' The following shapes id 3, 4 and 7 to 14 are composite symbols and should not be used.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive points to a ggplot -------
#' @example examples/geom_point_interactive.R
#' @seealso [girafe()]
#' @export
geom_point_interactive <- function(...)
  layer_interactive(geom_point, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractivePoint <- ggproto(
  "GeomInteractivePoint",
  GeomPoint,
  default_aes = add_default_interactive_aes(GeomPoint),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(self, data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    zz <- GeomPoint$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    add_interactive_attrs(zz, coords, ipar = .ipar)
  }
)
