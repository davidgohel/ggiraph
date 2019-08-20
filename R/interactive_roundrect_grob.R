#' @title Generate interactive rectangle grob
#'
#' @description
#' The grob is based on \code{\link[grid]{roundrectGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @param tooltip tooltip associated with rectangles
#' @param onclick javascript action to execute when rectangle is clicked
#' @param data_id identifiers to associate with rectangles
#' @param cl class to set
#' @export
interactive_roundrect_grob <-
  function(...,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           cl = "interactive_roundrect_grob") {
    gr <- grid::roundrectGrob(...)
    add_interactive_attrs(gr,
                          get_interactive_attrs(),
                          cl = cl)
  }

#' @export
#' @title interactive_roundrect_grob drawing
#' @description draw an interactive_roundrect_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_roundrect_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.roundrect, x[grob_argnames(x = x, grob = grid::roundrectGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
