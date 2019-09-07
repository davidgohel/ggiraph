#' @title Create interactive gradient colour scales
#' @description These scales are based on
#' \code{\link[ggplot2]{scale_colour_gradient}} and
#' \code{\link[ggplot2]{scale_fill_gradient}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive functions
#' @seealso \code{\link{girafe}}
#' @export
#' @name scale_gradient_interactive
#' @family interactive scale
scale_colour_gradient_interactive <- function(...)
  scale_interactive(scale_colour_gradient, ...)

#' @export
#' @rdname scale_gradient_interactive
scale_color_gradient_interactive <- scale_colour_gradient_interactive

#' @export
#' @rdname scale_gradient_interactive
scale_fill_gradient_interactive <- function(...)
  scale_interactive(scale_fill_gradient, ...)
