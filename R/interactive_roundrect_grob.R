#' @title Create interactive rectangle grob
#'
#' @description
#' The grob is based on [roundrectGrob()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_roundrect_grob <- function(...) {
  grob_interactive(grid::roundrectGrob, ...)
}

#' @export
makeContent.interactive_roundrect_grob <- function(x) {
  gr <- NextMethod()
  add_interactive_attrs(gr, x)
}
