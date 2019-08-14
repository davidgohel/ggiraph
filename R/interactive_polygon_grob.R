#' @title Generate interactive grob polygons
#' @description This function can be used to generate interactive grob
#' polygons.
#'
#' @inheritParams grid::polygonGrob
#' @param tooltip tooltip associated with polygons
#' @param onclick javascript action to execute when polygon is clicked
#' @param data_id identifiers to associate with polygons
#' @param cl class to set
#' @export
interactive_polygon_grob <-
  function(x = unit(c(0, 1), "npc"),
           y = unit(c(0, 1), "npc"),
           id = NULL,
           id.lengths = NULL,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           default.units = "npc",
           name = NULL,
           gp = gpar(),
           vp = NULL,
           cl = "interactive_polygon_grob") {
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
      name = name,
      gp = gp,
      vp = vp,
      cl = cl
    )
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
  }
  interactive_attr_toxml(x = x, ids = ids, rows = posid)
  invisible()
}
