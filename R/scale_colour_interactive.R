#' @title Create interactive colour scales
#' @description These scales are based on
#' \code{\link[ggplot2]{scale_colour_continuous}},
#' \code{\link[ggplot2]{scale_fill_continuous}},
#' \code{\link[ggplot2]{scale_colour_grey}},
#' \code{\link[ggplot2]{scale_fill_grey}},
#' \code{\link[ggplot2]{scale_colour_hue}} and
#' \code{\link[ggplot2]{scale_fill_hue}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @seealso \code{\link{girafe}}
#' @export
#' @name scale_colour_interactive
#' @family interactive scale
scale_colour_continuous_interactive <- function(...)
  scale_interactive(scale_colour_continuous, ...)

#' @export
#' @rdname scale_colour_interactive
scale_color_continuous_interactive <- scale_colour_continuous_interactive

#' @export
#' @rdname scale_colour_interactive
scale_fill_continuous_interactive <- function(...)
  scale_interactive(scale_fill_continuous, ...)

#' @export
#' @rdname scale_colour_interactive
scale_colour_grey_interactive <- function(...)
  scale_interactive(scale_colour_grey, ...)

#' @export
#' @rdname scale_colour_interactive
scale_color_grey_interactive <- scale_colour_grey_interactive

#' @export
#' @rdname scale_colour_interactive
scale_fill_grey_interactive <- function(...)
  scale_interactive(scale_fill_grey, ...)

#' @export
#' @rdname scale_colour_interactive
scale_colour_hue_interactive <- function(...)
  scale_interactive(scale_colour_hue, ...)

#' @export
#' @rdname scale_colour_interactive
scale_color_hue_interactive <- scale_colour_hue_interactive

#' @export
#' @rdname scale_colour_interactive
scale_fill_hue_interactive <- function(...)
  scale_interactive(scale_fill_hue, ...)
