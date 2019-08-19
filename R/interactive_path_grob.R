#' @title Generate interactive path grob
#'
#' @description
#' The grob is based on \code{\link[grid]{pathGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @param tooltip tooltip associated with paths
#' @param onclick javascript action to execute when path is clicked
#' @param data_id identifiers to associate with paths
#' @param cl class to set
#' @export
interactive_path_grob <-
  function(...,
           tooltip = NULL,
           onclick = NULL,
           data_id = NULL,
           cl = "interactive_path_grob") {
    gr <- grid::pathGrob(...)
    add_interactive_attrs(gr,
                          get_interactive_attrs(),
                          cl = cl)
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
