#' @title Create interactive heatmaps of 2d bin counts
#'
#' @description
#' The geometry is based on [ggplot2::geom_bin_2d()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive bin2d heatmap to a ggplot -------
#' @example examples/geom_bin2d_interactive.R
#' @seealso [girafe()]
#' @export
geom_bin_2d_interactive <- function(...) {
  layer_interactive(geom_bin_2d, ..., interactive_geom = GeomInteractiveTile)
}

#' @export
#' @rdname geom_bin_2d_interactive
#' @usage NULL
geom_bin2d_interactive <- geom_bin_2d_interactive
