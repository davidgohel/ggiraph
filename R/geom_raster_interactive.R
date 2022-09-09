#' @title Create interactive raster rectangles
#'
#' @description
#' The geometry is based on [geom_raster()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @seealso [girafe()]
#' @examples
#' # add interactive raster to a ggplot -------
#' @example examples/geom_raster_interactive.R
#' @seealso [girafe()]
#' @export
geom_raster_interactive <- function(...)
  layer_interactive(geom_raster, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveRaster <- ggproto(
  "GeomInteractiveRaster",
  GeomRaster,
  default_aes = add_default_interactive_aes(GeomRaster),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    zz <- GeomRaster$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    coords <- coords[1,, drop = FALSE]
    add_interactive_attrs(zz, coords, ipar = .ipar)
  }
)
