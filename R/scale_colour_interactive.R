#' @title Create interactive colour scales
#' @description These scales are based on
#' [scale_colour_continuous()],
#' [scale_fill_continuous()],
#' [scale_colour_grey()],
#' [scale_fill_grey()],
#' [scale_colour_hue()],
#' [scale_fill_hue()],
#' [scale_colour_binned()],
#' [scale_fill_binned()],
#' [scale_colour_discrete()],
#' [scale_fill_discrete()],
#' [scale_colour_date()],
#' [scale_fill_date()],
#' [scale_colour_datetime()] and
#' [scale_fill_datetime()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @seealso [girafe()]
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

#' @export
#' @rdname scale_colour_interactive
scale_colour_binned_interactive <- function(...)
  scale_interactive(scale_colour_binned, ...)

#' @export
#' @rdname scale_colour_interactive
scale_color_binned_interactive <- scale_colour_binned_interactive

#' @export
#' @rdname scale_colour_interactive
scale_fill_binned_interactive <- function(...)
  scale_interactive(scale_fill_binned, ...)

#' @export
#' @rdname scale_colour_interactive
scale_colour_discrete_interactive <- function(...)
  scale_interactive(scale_colour_discrete, ...)

#' @export
#' @rdname scale_colour_interactive
scale_color_discrete_interactive <- scale_colour_discrete_interactive

#' @export
#' @rdname scale_colour_interactive
scale_fill_discrete_interactive <- function(...)
  scale_interactive(scale_fill_discrete, ...)

#' @export
#' @rdname scale_colour_interactive
scale_colour_date_interactive <- function(...)
  scale_interactive(scale_colour_date, ...)

#' @export
#' @rdname scale_colour_interactive
scale_color_date_interactive <- scale_colour_date_interactive

#' @export
#' @rdname scale_colour_interactive
scale_fill_date_interactive <- function(...)
  scale_interactive(scale_fill_date, ...)

#' @export
#' @rdname scale_colour_interactive
scale_colour_datetime_interactive <- function(...)
  scale_interactive(scale_colour_datetime, ...)

#' @export
#' @rdname scale_colour_interactive
scale_color_datetime_interactive <- scale_colour_datetime_interactive

#' @export
#' @rdname scale_colour_interactive
scale_fill_datetime_interactive <- function(...)
  scale_interactive(scale_fill_datetime, ...)
