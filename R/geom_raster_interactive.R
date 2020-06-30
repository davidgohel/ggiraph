#' @title Create interactive raster rectangles
#'
#' @description
#' The geometry is based on [geom_raster()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
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
  draw_key = function(data, params, size) {
    gr <- GeomRaster$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord, interpolate = FALSE,
                        hjust = 0.5, vjust = 0.5) {
    zz <- GeomRaster$draw_panel(
      data,
      panel_params,
      coord,
      interpolate = interpolate,
      hjust = hjust,
      vjust = vjust
    )
    coords <- coord$transform(data, panel_params)

    coords <- coords[1,, drop = FALSE]
    coords <- force_interactive_aes_to_char(coords)
    add_interactive_attrs(zz, coords)
  }
)
