#' @title Create interactive raster annotations
#'
#' @description
#' The layer is based on [ggplot2::annotation_raster()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for annotate_*_interactive functions
#' @examples
#' # add interactive raster annotation to a ggplot -------
#' @example examples/annotation_raster_interactive.R
#' @seealso [girafe()]
#' @export
annotation_raster_interactive <- function(...)
  layer_interactive(annotation_raster, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveRasterAnn <- ggproto(
  "GeomInteractiveRasterAnn",
  GeomRasterAnn,
  default_aes = add_default_interactive_aes(GeomRasterAnn),
  parameters = interactive_geom_parameters,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    zz <- GeomRasterAnn$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    coords <- coords[1,, drop = FALSE]
    add_interactive_attrs(zz, coords, ipar = .ipar)
  }
)
