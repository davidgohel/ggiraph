#' @title Create interactive scales for shapes
#' @description These scales are based on
#' [scale_shape()],
#' [scale_shape_continuous()],
#' [scale_shape_discrete()],
#' [scale_shape_binned()] and
#' [scale_shape_ordinal()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @seealso [girafe()]
#' @export
#' @name scale_shape_interactive
#' @family interactive scale
scale_shape_interactive <- function(...)
  scale_interactive(scale_shape, ...)

#' @export
#' @rdname scale_shape_interactive
scale_shape_continuous_interactive <- function(...)
  scale_interactive(scale_shape_continuous, ...)

#' @export
#' @rdname scale_shape_interactive
scale_shape_discrete_interactive <- function(...)
  scale_interactive(scale_shape_discrete, ...)

#' @export
#' @rdname scale_shape_interactive
scale_shape_binned_interactive <- function(...)
  scale_interactive(scale_shape_binned, ...)

#' @export
#' @rdname scale_shape_interactive
scale_shape_ordinal_interactive <- function(...)
  scale_interactive(scale_shape_ordinal, ...)
