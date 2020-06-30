#' @title Create interactive polygon grob
#'
#' @description
#' The grob is based on [polygonGrob()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_polygon_grob <- function(...) {
  grob_interactive(grid::polygonGrob, ...)
}

#' @export
drawDetails.interactive_polygon_grob <- function(x, recording) {
  dsvg_tracer_on()
  NextMethod()
  ids <- dsvg_tracer_off()
  if (length(ids) > 0) {
    if (is.null(x$id))
      x$id <- rep(1, length(x$x))
    posid = which(!duplicated(x$id))
    interactive_attr_toxml(x = x, ids = ids, rows = posid)
  }
  invisible()
}
