#' @title Create interactive colour scales
#' @description These scales are based on
#' \code{\link[ggplot2]{scale_colour_continuous}},
#' \code{\link[ggplot2]{scale_fill_continuous}},
#' \code{\link[ggplot2]{scale_colour_grey}},
#' \code{\link[ggplot2]{scale_fill_grey}},
#' \code{\link[ggplot2]{scale_colour_hue}},
#' \code{\link[ggplot2]{scale_fill_hue}},
#' \code{\link[ggplot2]{scale_colour_binned}},
#' \code{\link[ggplot2]{scale_fill_binned}},
#' \code{\link[ggplot2]{scale_colour_discrete}},
#' \code{\link[ggplot2]{scale_fill_discrete}},
#' \code{\link[ggplot2]{scale_colour_date}},
#' \code{\link[ggplot2]{scale_fill_date}},
#' \code{\link[ggplot2]{scale_colour_datetime}} and
#' \code{\link[ggplot2]{scale_fill_datetime}}.
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
