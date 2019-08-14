#' @title interactive annotations
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{annotate}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add interactive annotation -------
#' @example examples/annotate_interactive.R
#' @seealso \code{\link{girafe}}
#' @export
#' @include utils.R
annotate_interactive <- function(...) {
  layer_interactive(annotate, ...)
}
