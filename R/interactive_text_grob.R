#' @title Generate interactive grob text
#' @description This function can be used to generate interactive grob
#' text.
#'
#' @inheritParams grid::textGrob
#' @param tooltip tooltip associated with rectangles
#' @param onclick javascript action to execute when rectangle is clicked
#' @param data_id identifiers to associate with rectangles
#' @param cl class to set
#' @export
interactive_text_grob <-
  function(label,
           x = unit(0.5, "npc"),
           y = unit(0.5, "npc"),
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           just = "centre",
           hjust = NULL,
           vjust = NULL,
           rot = 0,
           check.overlap = FALSE,
           default.units = "npc",
           name = NULL,
           gp = gpar(),
           vp = NULL,
           cl = "interactive_text_grob") {
    if (!is.unit(x))
      x <- unit(x, default.units)
    if (!is.unit(y))
      y <- unit(y, default.units)
    grob(
      tooltip = tooltip,
      onclick = onclick,
      data_id = data_id,
      label = label,
      x = x,
      y = y,
      just = just,
      hjust = hjust,
      vjust = vjust,
      rot = rot,
      check.overlap = check.overlap,
      name = name,
      gp = gp,
      vp = vp,
      cl = cl
    )
  }

#' @export
#' @title interactive_text_grob drawing
#' @description draw an interactive_text_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_text_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.text, x[grob_argnames(x = x, grob = grid::textGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
