#' @title Create interactive gradient colour scales
#' @description These scales are based on
#' [scale_colour_gradient()],
#' [scale_fill_gradient()],
#' [scale_colour_gradient2()],
#' [scale_fill_gradient2()],
#' [scale_colour_gradientn()] and
#' [scale_fill_gradientn()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @examples
#' # add interactive gradient colour scale to a ggplot -------
#' @example examples/scale_gradient_guide_colourbar_interactive.R
#' @seealso [girafe()]
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

#' @export
#' @rdname scale_gradient_interactive
scale_colour_gradient2_interactive <- function(...)
  scale_interactive(scale_colour_gradient2, ...)

#' @export
#' @rdname scale_gradient_interactive
scale_color_gradient2_interactive <- scale_colour_gradient2_interactive

#' @export
#' @rdname scale_gradient_interactive
scale_fill_gradient2_interactive <- function(...)
  scale_interactive(scale_fill_gradient2, ...)

#' @export
#' @rdname scale_gradient_interactive
scale_colour_gradientn_interactive <- function(...)
  scale_interactive(scale_colour_gradientn, ...)

#' @export
#' @rdname scale_gradient_interactive
scale_color_gradientn_interactive <- scale_colour_gradientn_interactive

#' @export
#' @rdname scale_gradient_interactive
scale_fill_gradientn_interactive <- function(...)
  scale_interactive(scale_fill_gradientn, ...)

