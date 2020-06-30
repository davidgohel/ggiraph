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
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
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
  draw_key = function(data, params, size) {
    gr <- GeomPoint$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord, na.rm = FALSE) {
    zz <- GeomPoint$draw_panel(data, panel_params, coord, na.rm = na.rm)
    coords <- coord$transform(data, panel_params)
    coords <- force_interactive_aes_to_char(coords)
    add_interactive_attrs(zz, coords)
  }
)
