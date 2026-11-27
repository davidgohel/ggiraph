#' @title Create interactive polygon grob
#'
#' @description
#' The grob is based on [polygonGrob()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
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
    if (is.null(x$id)) {
      if (is.null(x$id.lengths)) {
        x$id <- rep(1, length(x$x))
      } else {
        n <- length(x$id.lengths)
        x$id <- rep(1L:n, x$id.lengths)
      }
    }
    posid <- which(!duplicated(x$id))
    # a polygon is cut at its missing points, each piece of at least two
    # points is drawn (as polylines, see polyline_element_counts())
    counts <- polyline_element_counts(x, x$id, filled = TRUE)
    if (sum(counts) == length(ids)) {
      posid <- rep(posid, counts)
    }
    interactive_attr_toxml(x = x, ids = ids, rows = posid)
  }
  invisible()
}
