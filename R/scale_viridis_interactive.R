#' @title Create interactive viridis colour scales
#' @description These scales are based on
#' \code{\link[ggplot2]{scale_colour_viridis_d}},
#' \code{\link[ggplot2]{scale_fill_viridis_d}},
#' \code{\link[ggplot2]{scale_colour_viridis_c}} and
#' \code{\link[ggplot2]{scale_fill_viridis_c}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive functions
#' @seealso \code{\link{girafe}}
#' @export
#' @name scale_viridis_interactive
#' @family interactive scale
scale_colour_viridis_d_interactive <- function(...)
  scale_interactive(scale_colour_viridis_d, ...)

#' @export
#' @rdname scale_viridis_interactive
scale_color_viridis_d_interactive <- scale_colour_viridis_d_interactive

#' @export
#' @rdname scale_viridis_interactive
scale_fill_viridis_d_interactive <- function(...)
  scale_interactive(scale_fill_viridis_d, ...)

#' @export
#' @rdname scale_viridis_interactive
scale_colour_viridis_c_interactive <- function(...)
  scale_interactive(scale_colour_viridis_c, ...)

#' @export
#' @rdname scale_viridis_interactive
scale_color_viridis_c_interactive <- scale_colour_viridis_c_interactive

#' @export
#' @rdname scale_viridis_interactive
scale_fill_viridis_c_interactive <- function(...)
  scale_interactive(scale_fill_viridis_c, ...)
