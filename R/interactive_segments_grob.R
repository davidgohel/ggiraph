#' @title Generate interactive grob segments
#' @description This function can be used to generate interactive grob
#' segments.
#'
#' @inheritParams grid::segmentsGrob
#' @param tooltip tooltip associated with segments
#' @param onclick javascript action to execute when segment is clicked
#' @param data_id identifiers to associate with segments
#' @param cl class to set
#' @export
interactive_segments_grob <-
  function(x0 = unit(0, "npc"),
           y0 = unit(0, "npc"),
           x1 = unit(1, "npc"),
           y1 = unit(1, "npc"),
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           default.units = "npc",
           arrow = NULL,
           name = NULL,
           gp = gpar(),
           vp = NULL,
           cl = "interactive_segments_grob") {
    # Allow user to specify unitless vector;  add default units
    if (!is.unit(x0))
      x0 <- unit(x0, default.units)
    if (!is.unit(x1))
      x1 <- unit(x1, default.units)
    if (!is.unit(y0))
      y0 <- unit(y0, default.units)
    if (!is.unit(y1))
      y1 <- unit(y1, default.units)
    grob(
      tooltip = tooltip,
      onclick = onclick,
      data_id = data_id,
      x0 = x0,
      y0 = y0,
      x1 = x1,
      y1 = y1,
      arrow = arrow,
      name = name,
      gp = gp,
      vp = vp,
      cl = cl
    )
  }

#' @export
#' @title interactive_segments_grob drawing
#' @description draw an interactive_segments_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_segments_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.segments, x[grob_argnames(x = x, grob = grid::segmentsGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
