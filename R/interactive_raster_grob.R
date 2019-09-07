#' @title Create interactive raster grob
#'
#' @description
#' The grob is based on \code{\link[grid]{rasterGrob}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso \code{\link{interactive_parameters}}
#' @seealso \code{\link{girafe}}
#' @export
interactive_raster_grob <- function(...) {
  grob_interactive(grid::rasterGrob, ...)
}

#' @export
drawDetails.interactive_raster_grob <- function(x, recording) {
  # ugly fix for beeing able to call grid.raster as argument name is raster and not image
  names(x)[names(x) %in% "raster"] <- "image"
  dsvg_tracer_on()
  do.call(grid.raster, x[grob_argnames(x = x, grob = grid::rasterGrob)])
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
