#' @title Create interactive point counts
#'
#' @description
#' The geometry is based on [geom_bin2d()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive point counts to a ggplot -------
#' @example examples/geom_count_interactive.R
#' @seealso [girafe()]
#' @export
geom_count_interactive <- function(...)
  layer_interactive(geom_count, ..., interactive_geom = GeomInteractivePoint)
