#' @title Create interactive annotations
#'
#' @description
#' The layer is based on [annotate()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for annotate_*_interactive functions
#' @examples
#' # add interactive annotation to a ggplot -------
#' @example examples/annotate_interactive.R
#' @seealso [girafe()], [interactive_parameters], [annotation_raster_interactive()]
#' @export
#' @include utils.R
annotate_interactive <- function(...)
  layer_interactive(annotate, ...)

