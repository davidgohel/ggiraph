#' @title Create interactive segments grob
#'
#' @description
#' The grob is based on \code{\link[grid]{segmentsGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso \code{\link{girafe}}
#' @export
interactive_segments_grob <- function(...) {
  grob_interactive(grid::segmentsGrob, ...)
}

#' @export
drawDetails.interactive_segments_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.segments, x[grob_argnames(x = x, grob = grid::segmentsGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
