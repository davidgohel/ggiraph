#' @title Create interactive curve grob
#'
#' @description
#' The grob is based on [curveGrob()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_curve_grob <- function(...) {
  grob_interactive(grid::curveGrob, ...)
}

#' @export
makeContent.interactive_curve_grob <- function(x) {
  gr <- NextMethod()
  data <- get_interactive_data(x)
  data_attr <- get_data_attr(x)
  ipar <- get_ipar(x)
  for (i in seq_along(gr$children)) {
    gr$children[[i]] <- add_interactive_attrs(
      gr$children[[i]], data = data, data_attr = data_attr, ipar = ipar
    )
  }
  gr
}

#' @export
drawDetails.interactive_xspline_grob <- function(x, recording) {
  dsvg_tracer_on()
  NextMethod()
  ids <- dsvg_tracer_off()
  interactive_attr_toxml(x = x, ids = ids)
  invisible()
}
