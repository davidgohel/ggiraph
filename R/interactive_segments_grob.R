#' @title Generate interactive segments grob
#'
#' @description
#' The grob is based on \code{\link[grid]{segmentsGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @param tooltip tooltip associated with segments
#' @param onclick javascript action to execute when segment is clicked
#' @param data_id identifiers to associate with segments
#' @param cl class to set
#' @export
interactive_segments_grob <-
  function(...,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           cl = "interactive_segments_grob") {
    gr <- grid::segmentsGrob(...)
    add_interactive_attrs(gr,
                          list(
                            tooltip = tooltip,
                            onclick = onclick,
                            data_id = data_id
                          ),
                          cl = cl)
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
