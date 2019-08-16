#' @title interactive raster rectangles.
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_raster}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @seealso \code{\link{girafe}}
#' @export
geom_raster_interactive <- function(...) {
  layer_interactive(geom_raster, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveRaster <- ggproto(
  "GeomInteractiveRaster",
  GeomRaster,
  default_aes = add_default_interactive_aes(GeomRaster),
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
    add_interactive_attrs(zz, coords, cl = "interactive_raster_grob")
  },
  draw_key = function(data, params, size) {
    gr <- draw_key_rect(data, params, size)
    add_interactive_attrs(gr, data, cl = NULL, data_attr = "key-id")
  }
)

#' @export
#' @title interactive_raster_grob drawing
#' @description draw an interactive_rect_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_raster_grob <- function(x, recording) {
  # ugly fix for beeing able to call grid.raster as argument name is raster and not image
  names(x)[names(x) %in% "raster"] <- "image"
  dsvg_tracer_on()
  do.call(grid.raster, x[grob_argnames(x = x, grob = grid::rasterGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}

