#' @title Create interactive quantile regression
#'
#' @description
#' The geometry is based on [geom_quantile()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive quantiles to a ggplot -------
#' @example examples/geom_quantile_interactive.R
#' @seealso [girafe()]
#' @export
geom_quantile_interactive <- function(...)
  layer_interactive(geom_quantile, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveQuantile <- ggproto(
  "GeomInteractiveQuantile",
  GeomInteractivePath,
  default_aes = add_default_interactive_aes(GeomQuantile)
)
