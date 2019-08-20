#' @title interactive annotations
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{annotation_raster}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add diagonal interactive reference lines to a ggplot -------
#' @example examples/annotation_raster_interactive.R
#' @seealso \code{\link{girafe}}
#' @export
#' @include utils.R
annotation_raster_interactive <- function(...) {
  layer_interactive(annotation_raster, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveRasterAnn <- ggproto(
  "GeomInteractiveRasterAnn",
  GeomRasterAnn,
  default_aes = add_default_interactive_aes(GeomRasterAnn),
  draw_panel = function(data, panel_params, coord, raster,
                        xmin, xmax, ymin, ymax, interpolate = FALSE) {
    zz <- GeomRasterAnn$draw_panel(
      data,
      panel_params,
      coord, raster,
      xmin, xmax, ymin, ymax,
      interpolate = interpolate
    )
    coords <- coord$transform(data, panel_params)
    coords <- coords[1,, drop = FALSE]
    coords <- force_interactive_aes_to_char(coords)
    add_interactive_attrs(zz, coords)
  }
)
