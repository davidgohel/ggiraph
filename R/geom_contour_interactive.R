#' @title Create interactive 2d contours of a 3d surface
#'
#' @description
#' These geometries are based on [geom_contour()]
#' and [geom_contour_filled()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive contours to a ggplot -------
#' @example examples/geom_contour_interactive.R
#' @seealso [girafe()]
#' @export
geom_contour_interactive <- function(...)
  layer_interactive(geom_contour, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveContour <- ggproto(
  "GeomInteractiveContour",
  GeomInteractivePath,
  default_aes = add_default_interactive_aes(GeomContour)
)

#' @export
#' @rdname geom_contour_interactive
#' @include geom_polygon_interactive.R
geom_contour_filled_interactive <- function(...)
  layer_interactive(geom_contour_filled, ..., interactive_geom = GeomInteractivePolygon)
