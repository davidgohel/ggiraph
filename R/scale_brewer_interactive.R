#' @title Create interactive colorbrewer scales
#' @description These scales are based on
#' [scale_colour_brewer()],
#' [scale_fill_brewer()],
#' [scale_colour_distiller()],
#' [scale_fill_distiller()],
#' [scale_colour_fermenter()],
#' [scale_fill_fermenter()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @seealso [girafe()]
#' @export
#' @name scale_colour_brewer_interactive
#' @family interactive scale
scale_colour_brewer_interactive <- function(...)
  scale_interactive(scale_colour_brewer, ...)

#' @export
#' @rdname scale_colour_brewer_interactive
scale_color_brewer_interactive <- scale_colour_brewer_interactive

#' @export
#' @rdname scale_colour_brewer_interactive
scale_fill_brewer_interactive <- function(...)
  scale_interactive(scale_fill_brewer, ...)

#' @export
#' @rdname scale_colour_brewer_interactive
scale_colour_distiller_interactive <- function(...)
  scale_interactive(scale_colour_distiller, ...)

#' @export
#' @rdname scale_colour_brewer_interactive
scale_color_distiller_interactive <- scale_colour_distiller_interactive

#' @export
#' @rdname scale_colour_brewer_interactive
scale_fill_distiller_interactive <- function(...)
  scale_interactive(scale_fill_distiller, ...)

#' @export
#' @rdname scale_colour_brewer_interactive
scale_colour_fermenter_interactive <- function(...)
  scale_interactive(scale_colour_fermenter, ...)

#' @export
#' @rdname scale_colour_brewer_interactive
scale_color_fermenter_interactive <- scale_colour_fermenter_interactive

#' @export
#' @rdname scale_colour_brewer_interactive
scale_fill_fermenter_interactive <- function(...)
  scale_interactive(scale_fill_fermenter, ...)
