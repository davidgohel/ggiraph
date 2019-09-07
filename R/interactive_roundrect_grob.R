#' @title Create interactive rectangle grob
#'
#' @description
#' The grob is based on \code{\link[grid]{roundrectGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso \code{\link{girafe}}
#' @export
interactive_roundrect_grob <- function(...) {
  grob_interactive(grid::roundrectGrob, ...)
}

#' @export
drawDetails.interactive_roundrect_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.roundrect, x[grob_argnames(x = x, grob = grid::roundrectGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
