#' @title Create interactive segments grob
#'
#' @description
#' The grob is based on [segmentsGrob][grid::grid.segments].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_segments_grob <- function(...) {
  grob_interactive(grid::segmentsGrob, ...)
}

#' @export
drawDetails.interactive_segments_grob <- function(x, recording) {
  dsvg_tracer_on()
  NextMethod()
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
