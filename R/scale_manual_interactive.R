#' @title Create your own interactive discrete scale
#' @description These scales are based on
#' \code{\link[ggplot2]{scale_colour_manual}} and
#' \code{\link[ggplot2]{scale_fill_manual}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive functions
#' @seealso \code{\link{girafe}}
#' @export
#' @name scale_manual_interactive
#' @family interactive scale
scale_colour_manual_interactive <- function(...)
  scale_interactive(scale_colour_manual, ...)

#' @export
#' @rdname scale_manual_interactive
scale_color_manual_interactive <- scale_colour_manual_interactive

#' @export
#' @rdname scale_manual_interactive
scale_fill_manual_interactive <- function(...)
  scale_interactive(scale_fill_manual, ...)
