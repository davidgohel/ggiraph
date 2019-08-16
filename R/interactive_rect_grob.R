#' @title Generate interactive rectangle grob
#'
#' @description
#' The grob is based on \code{\link[grid]{rectGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @param tooltip tooltip associated with rectangles
#' @param onclick javascript action to execute when rectangle is clicked
#' @param data_id identifiers to associate with rectangles
#' @param cl class to set
#' @export
interactive_rect_grob <-
  function(...,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           cl = "interactive_rect_grob") {
    gr <- grid::rectGrob(...)
    add_interactive_attrs(gr,
                          list(
                            tooltip = tooltip,
                            onclick = onclick,
                            data_id = data_id
                          ),
                          cl = cl)
  }

#' @export
#' @title interactive_rect_grob drawing
#' @description draw an interactive_rect_grob
#' @inheritParams grid::drawDetails
drawDetails.interactive_rect_grob <- function(x, recording) {
  dsvg_tracer_on()
  do.call(grid.rect, x[grob_argnames(x = x, grob = grid::rectGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
