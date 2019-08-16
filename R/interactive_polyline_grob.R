#' @title Generate interactive polyline grob
#'
#' @description
#' The grob is based on \code{\link[grid]{polylineGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @param tooltip tooltip associated with polylines
#' @param onclick javascript action to execute when polyline is clicked
#' @param data_id identifiers to associate with polylines
#' @param cl class to set
#' @export
interactive_polyline_grob <-
  function(...,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           cl = "interactive_polyline_grob") {
    gr <- grid::polylineGrob(...)
    add_interactive_attrs(gr,
                          list(
                            tooltip = tooltip,
                            onclick = onclick,
                            data_id = data_id
                          ),
                          cl = cl)
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
