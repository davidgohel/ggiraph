#' @title Generate interactive grob paths
#' @description This function can be used to generate interactive grob
#' paths
#'
#' @inheritParams grid::pathGrob
#' @param tooltip tooltip associated with polygons
#' @param onclick javascript action to execute when polygon is clicked
#' @param data_id identifiers to associate with polygons
#' @param cl class to set
#' @export
interactive_path_grob <-
  function(x,
           y,
           id = NULL,
           id.lengths = NULL,
           pathId = NULL,
           pathId.lengths = NULL,
           rule = "winding",
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           default.units = "npc",
           name = NULL,
           gp = gpar(),
           vp = NULL,
           cl = "interactive_path_grob") {
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
      pathId = pathId,
      pathId.lengths = pathId.lengths,
      rule = rule,
      name = name,
      gp = gp,
      vp = vp,
      cl = cl
    )
  }

#' @export
#' @title interactive_path_grob drawing
#' @description draw an interactive_path_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_path_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.path, x[grob_argnames(x = x, grob = grid::pathGrob)])
  ids <- dsvg_tracer_off()
  if (length(ids) > 0) {
    if (is.null(x$id))
      x$id <- rep(1, length(x$x))
    posid = which(!duplicated(x$id))
    interactive_attr_toxml(x = x, ids = ids, rows = posid)
  }
  invisible()
}
