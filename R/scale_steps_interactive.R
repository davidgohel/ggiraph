#' @title Create interactive binned gradient colour scales
#' @description These scales are based on
#' \code{\link[ggplot2]{scale_colour_steps}},
#' \code{\link[ggplot2]{scale_fill_steps}},
#' \code{\link[ggplot2]{scale_colour_steps2}},
#' \code{\link[ggplot2]{scale_fill_steps2}},
#' \code{\link[ggplot2]{scale_colour_stepsn}} and
#' \code{\link[ggplot2]{scale_fill_stepsn}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @seealso \code{\link{girafe}}
#' @export
#' @name scale_colour_steps_interactive
#' @family interactive scale
scale_colour_steps_interactive <- function(...)
  scale_interactive(scale_colour_steps, ...)

#' @export
#' @rdname scale_colour_steps_interactive
scale_color_steps_interactive <- scale_colour_steps_interactive

#' @export
#' @rdname scale_colour_steps_interactive
scale_fill_steps_interactive <- function(...)
  scale_interactive(scale_fill_steps, ...)

#' @export
#' @rdname scale_colour_steps_interactive
scale_colour_steps2_interactive <- function(...)
  scale_interactive(scale_colour_steps2, ...)

#' @export
#' @rdname scale_colour_steps_interactive
scale_color_steps2_interactive <- scale_colour_steps2_interactive

#' @export
#' @rdname scale_colour_steps_interactive
scale_fill_steps2_interactive <- function(...)
  scale_interactive(scale_fill_steps2, ...)

#' @export
#' @rdname scale_colour_steps_interactive
scale_colour_stepsn_interactive <- function(...)
  scale_interactive(scale_colour_stepsn, ...)

#' @export
#' @rdname scale_colour_steps_interactive
scale_color_stepsn_interactive <- scale_colour_stepsn_interactive

#' @export
#' @rdname scale_colour_steps_interactive
scale_fill_stepsn_interactive <- function(...)
  scale_interactive(scale_fill_stepsn, ...)
