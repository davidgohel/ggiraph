#' @title Create interactive histograms and frequency polygons
#'
#' @description
#' The geometries are based on [geom_histogram()]
#' and [geom_freqpoly()].
#' See the documentation for those functions for more details.
#'
#' This interactive version is only providing a single tooltip per
#' group of data (same for \code{data_id}). It means it is only possible
#' to associate a single tooltip to a set of bins.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive histogram -------
#' @example examples/geom_histogram_interactive.R
#' @seealso [girafe()]
#' @export
geom_histogram_interactive <- function(...)
  layer_interactive(geom_histogram, ...)
