#' @title Generate interactive points grob
#'
#' @description
#' The grob is based on \code{\link[grid]{pointsGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @param tooltip tooltip associated with points
#' @param onclick javascript action to execute when point is clicked
#' @param data_id identifiers to associate with points
#' @param cl class to set
#' @export
interactive_points_grob <-
  function(...,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           cl = "interactive_points_grob") {
    gr <- grid::pointsGrob(...)
    add_interactive_attrs(gr,
                          get_interactive_attrs(),
                          cl = cl)
  }

#' @export
#' @title interactive_points_grob drawing
#' @description draw an interactive_points_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_points_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.points, x[grob_argnames(x = x, grob = grid::pointsGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
