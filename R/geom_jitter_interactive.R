#' @title Create interactive jittered points
#'
#' @description
#' The geometry is based on [geom_jitter()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive paths to a ggplot -------
#' @example examples/geom_jitter_interactive.R
#' @seealso [girafe()]
#' @export
geom_jitter_interactive <- function(...)
  layer_interactive(geom_jitter, ...)
