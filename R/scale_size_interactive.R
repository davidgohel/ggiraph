#' @title Create interactive scales for area or radius
#' @description These scales are based on
#' [scale_size()],
#' [scale_size_area()],
#' [scale_size_continuous()],
#' [scale_size_discrete()],
#' [scale_size_binned()],
#' [scale_size_binned_area()],
#' [scale_size_date()],
#' [scale_size_datetime()],
#' [scale_size_ordinal()] and
#' [scale_radius()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @seealso [girafe()]
#' @export
#' @name scale_size_interactive
#' @family interactive scale
scale_size_interactive <- function(...)
  scale_interactive(scale_size, ...)

#' @export
#' @rdname scale_size_interactive
scale_size_area_interactive <- function(...)
  scale_interactive(scale_size_area, ...)

#' @export
#' @rdname scale_size_interactive
scale_size_continuous_interactive <- function(...)
  scale_interactive(scale_size_continuous, ...)

#' @export
#' @rdname scale_size_interactive
scale_size_discrete_interactive <- function(...)
  scale_interactive(scale_size_discrete, ...)

#' @export
#' @rdname scale_size_interactive
scale_size_binned_interactive <- function(...)
  scale_interactive(scale_size_binned, ...)

#' @export
#' @rdname scale_size_interactive
scale_size_binned_area_interactive <- function(...)
  scale_interactive(scale_size_binned_area, ...)

#' @export
#' @rdname scale_size_interactive
scale_size_date_interactive <- function(...)
  scale_interactive(scale_size_date, ...)

#' @export
#' @rdname scale_size_interactive
scale_size_datetime_interactive <- function(...)
  scale_interactive(scale_size_datetime, ...)

#' @export
#' @rdname scale_size_interactive
scale_size_ordinal_interactive <- function(...)
  scale_interactive(scale_size_ordinal, ...)

#' @export
#' @rdname scale_size_interactive
scale_radius_interactive <- function(...)
  scale_interactive(scale_radius, ...)
