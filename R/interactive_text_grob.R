#' @title Create interactive text grob
#'
#' @description
#' The grob is based on \code{\link[grid]{textGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso \code{\link{girafe}}
#' @export
interactive_text_grob <- function(...) {
  grob_interactive(grid::textGrob, ...)
}

#' @export
#' @title interactive_text_grob drawing
#' @description draw an interactive_text_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_text_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.text, x[grob_argnames(x = x, grob = grid::textGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
