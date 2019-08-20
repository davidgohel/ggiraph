#' @title Generate interactive polygon grob
#'
#' @description
#' The grob is based on \code{\link[grid]{polygonGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @param tooltip tooltip associated with polygons
#' @param onclick javascript action to execute when polygon is clicked
#' @param data_id identifiers to associate with polygons
#' @param cl class to set
#' @export
interactive_polygon_grob <-
  function(...,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           cl = "interactive_polygon_grob") {
    gr <- grid::polygonGrob(...)
    add_interactive_attrs(gr,
                          get_interactive_attrs(),
                          cl = cl)
  }

#' @export
#' @title interactive_polygon_grob drawing
#' @description draw an interactive_polygon_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_polygon_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.polygon, x[grob_argnames(x = x, grob = grid::polygonGrob)])
  ids <- dsvg_tracer_off()
  if (length(ids) > 0) {
    if (is.null(x$id))
      x$id <- rep(1, length(x$x))
    posid = which(!duplicated(x$id))
    interactive_attr_toxml(x = x, ids = ids, rows = posid)
  }
  invisible()
}
