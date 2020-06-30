#' @title Create your own interactive discrete scale
#' @description These scales are based on
#' [scale_colour_manual()],
#' [scale_fill_manual()],
#' [scale_size_manual()],
#' [scale_shape_manual()],
#' [scale_linetype_manual()],
#' [scale_alpha_manual()] and
#' [scale_discrete_manual()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @examples
#' # add interactive manual fill scale to a ggplot -------
#' @example examples/scale_manual_guide_legend_discrete_interactive.R
#' @seealso [girafe()]
#' @export
#' @name scale_manual_interactive
#' @family interactive scale
scale_colour_manual_interactive <- function(...)
  scale_interactive(scale_colour_manual, ...)

#' @export
#' @rdname scale_manual_interactive
scale_color_manual_interactive <- scale_colour_manual_interactive

#' @export
#' @rdname scale_manual_interactive
scale_fill_manual_interactive <- function(...)
  scale_interactive(scale_fill_manual, ...)

#' @export
#' @rdname scale_manual_interactive
scale_size_manual_interactive <- function(...)
  scale_interactive(scale_size_manual, ...)

#' @export
#' @rdname scale_manual_interactive
scale_shape_manual_interactive <- function(...)
  scale_interactive(scale_shape_manual, ...)

#' @export
#' @rdname scale_manual_interactive
scale_linetype_manual_interactive <- function(...)
  scale_interactive(scale_linetype_manual, ...)

#' @export
#' @rdname scale_manual_interactive
scale_alpha_manual_interactive <- function(...)
  scale_interactive(scale_alpha_manual, ...)

#' @export
#' @rdname scale_manual_interactive
scale_discrete_manual_interactive <- function(...)
  scale_interactive(scale_discrete_manual, ...)
