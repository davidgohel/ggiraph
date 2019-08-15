#' @title Generate an Interactive Grob Path
#' @description This function can be used to generate an interactive grob
#' path.
#'
#' @inheritParams grid::polylineGrob
#' @param tooltip tooltip associated with polylines
#' @param onclick javascript action to execute when polyline is clicked
#' @param data_id identifiers to associate with polylines
#' @param cl class to set
#' @export
interactive_polyline_grob <-
  function(x = unit(c(0, 1), "npc"),
           y = unit(c(0, 1), "npc"),
           id = NULL,
           id.lengths = NULL,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           default.units = "npc",
           arrow = NULL,
           name = NULL,
           gp = gpar(),
           vp = NULL,
           cl = "interactive_polyline_grob") {
    # Allow user to specify unitless vector;  add default units
    if (!is.unit(x))
      x <- unit(x, default.units)
    if (!is.unit(y))
      y <- unit(y, default.units)
    grob(
      tooltip = tooltip,
      onclick = onclick,
      data_id = data_id,
      x = x,
      y = y,
      id = id,
      id.lengths = id.lengths,
      arrow = arrow,
      name = name,
      gp = gp,
      vp = vp,
      cl = cl
    )
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
