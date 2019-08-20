#' @title interactive 2d contours of a 3d surface.
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_contour}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @seealso \code{\link{girafe}}
#' @examples
#' # add interactive contours to a ggplot -------
#' @example examples/geom_contour_interactive.R
#' @seealso \code{\link{girafe}}
#' @export
geom_contour_interactive <- function(...) {
  layer_interactive(geom_contour, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveContour <- ggproto(
  "GeomInteractiveContour",
  GeomInteractivePath,
  default_aes = add_default_interactive_aes(GeomContour)
)
