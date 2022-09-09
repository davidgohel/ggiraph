#' @title Create interactive hexagonal heatmaps
#'
#' @description
#' The geometry is based on [geom_hex()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive hexagonal heatmaps to a ggplot -------
#' @example examples/geom_hex_interactive.R
#' @seealso [girafe()]
#' @export
geom_hex_interactive <- function(...)
  layer_interactive(geom_hex, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveHex <- ggproto(
  "GeomInteractiveHex",
  GeomHex,
  default_aes = add_default_interactive_aes(GeomHex),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    zz <- GeomHex$draw_group(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    tmp <- new_data_frame(n = length(zz$x))
    tmp <- copy_interactive_attrs(coords, tmp, each = 6, ipar = .ipar)
    add_interactive_attrs(zz, tmp, ipar = .ipar)
  }
)
