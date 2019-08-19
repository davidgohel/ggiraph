#' @title Generate interactive text grob
#'
#' @description
#' The grob is based on \code{\link[grid]{textGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @param tooltip tooltip associated with texts
#' @param onclick javascript action to execute when text is clicked
#' @param data_id identifiers to associate with texts
#' @param cl class to set
#' @export
interactive_text_grob <-
  function(...,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           cl = "interactive_text_grob") {
    gr <- grid::textGrob(...)
    add_interactive_attrs(gr,
                          get_interactive_attrs(),
                          cl = cl)
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
