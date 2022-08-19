#' @title Create interactive contours of a 2d density estimate
#'
#' @description
#' The geometries are based on [geom_density_2d()] and [geom_density_2d_filled()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive contours to a ggplot -------
#' @example examples/geom_density_2d_interactive.R
#' @seealso [girafe()]
#' @export
geom_density_2d_interactive <- function(...)
  layer_interactive(geom_density_2d, ...)

#' @export
#' @rdname geom_density_2d_interactive
#' @usage NULL
geom_density2d_interactive <- geom_density_2d_interactive

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveDensity2d <- ggproto(
  "GeomInteractiveDensity2d",
  GeomInteractivePath,
  default_aes = add_default_interactive_aes(GeomDensity2d),
  parameters = interactive_geom_parameters
)

#' @rdname geom_density_2d_interactive
#' @export
geom_density_2d_filled_interactive <- function(...)
  layer_interactive(geom_density_2d_filled, ...)

#' @export
#' @rdname geom_density_2d_interactive
#' @usage NULL
geom_density2d_filled_interactive <- geom_density_2d_filled_interactive

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveDensity2dFilled <- ggproto(
  "GeomInteractiveDensity2dFilled",
  GeomInteractivePolygon,
  default_aes = add_default_interactive_aes(GeomDensity2dFilled)
)
