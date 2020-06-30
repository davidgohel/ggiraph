#' @title Create interactive scales for area or radius
#' @description These scales are based on
#' [scale_size][ggplot2::scale_size],
#' [scale_size_area][ggplot2::scale_size],
#' [scale_size_continuous][ggplot2::scale_size],
#' [scale_size_discrete][ggplot2::scale_size],
#' [scale_size_binned][ggplot2::scale_size],
#' [scale_size_binned_area][ggplot2::scale_size],
#' [scale_size_date][ggplot2::scale_size],
#' [scale_size_datetime][ggplot2::scale_size],
#' [scale_size_ordinal][ggplot2::scale_size] and
#' [scale_radius][ggplot2::scale_size].
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
