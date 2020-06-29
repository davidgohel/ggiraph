#' @title Create interactive text grob
#'
#' @description
#' The grob is based on [textGrob][grid::grid.text].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_text_grob <- function(...) {
  grob_interactive(grid::textGrob, ...)
}

#' @export
drawDetails.interactive_text_grob <- function(x, recording) {
  dsvg_tracer_on()
  NextMethod()
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
