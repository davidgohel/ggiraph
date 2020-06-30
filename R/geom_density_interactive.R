#' @title Create interactive smoothed density estimates
#'
#' @description
#' The geometry is based on [geom_density()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive bar -------
#' @example examples/geom_density_interactive.R
#' @seealso [girafe()]
#' @export
geom_density_interactive <- function(...)
  layer_interactive(geom_density, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveDensity <- ggproto(
  "GeomInteractiveDensity",
  GeomDensity,
  default_aes = add_default_interactive_aes(GeomDensity),
  draw_key = function(data, params, size) {
    gr <- GeomDensity$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_group = function(data, panel_params, coord, na.rm = FALSE) {
    GeomInteractiveArea$draw_group(data, panel_params, coord, na.rm = na.rm)
  }
)
