#' @title Create interactive polyline grob
#'
#' @description
#' These grobs are based on \code{\link[grid]{polylineGrob}} and
#' \code{\link[grid]{linesGrob}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso \code{\link{girafe}}
#' @export
interactive_polyline_grob <- function(...) {
  grob_interactive(grid::polylineGrob, ...)
}

#' @export
#' @title interactive_polyline_grob drawing
#' @description draw an interactive_polyline_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_polyline_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.polyline, x[grob_argnames(x = x, grob = grid::polylineGrob)])
  ids <- dsvg_tracer_off()
  if (length(ids) > 0) {
    if (is.null(x$id) && is.null(x$id.lengths))
      x$id <- rep(1, length(x$x))
    .w = c(TRUE, x$id[-1] != x$id[-length(x$id)])
    interactive_attr_toxml(x = x, ids = ids, rows = .w)
  }
  invisible()
}

#' @rdname interactive_polyline_grob
#' @export
interactive_lines_grob <- function(...) {
  grob_interactive(grid::linesGrob, ...)
}

#' @export
#' @title interactive_lines_grob drawing
#' @description draw an interactive_lines_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_lines_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.lines, x[grob_argnames(x = x, grob = grid::linesGrob)])
  ids <- dsvg_tracer_off()
  if (length(ids) > 0) {
    if (is.null(x$id) && is.null(x$id.lengths))
      x$id <- rep(1, length(x$x))
    .w = c(TRUE, x$id[-1] != x$id[-length(x$id)])
    interactive_attr_toxml(x = x, ids = ids, rows = .w)
  }
  invisible()
}
