#' @title Create a ggiraph object (defunct)
#'
#' @description Create an interactive graphic to be used in a web browser.
#'
#' This function is now defunct, users should
#' now use function [girafe()].
#'
#' @param ... unused
#' @export
#' @keywords internal
ggiraph <- function(...) {
  .Defunct(new = "girafe")
}



#' @title Create a ggiraph output element
#' @description Render a ggiraph within an application page.
#'
#' This function is now defunct, users should
#' now use function [girafeOutput()].
#' @param ... unused
#' @export
#' @keywords internal
ggiraphOutput <- function(...){
  .Defunct(new = "girafeOutput")
}

#' @title Reactive version of ggiraph object
#'
#' @description Makes a reactive version of a ggiraph object for use in Shiny.
#'
#' This function is now defunct, users should
#' now use function [renderGirafe()].
#' @param ... unused
#' @export
#' @keywords internal
renderggiraph <- function(...) {
  .Defunct(new = "renderGirafe")
}

