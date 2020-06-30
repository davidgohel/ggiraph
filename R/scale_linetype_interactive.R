#' @title Create interactive scales for line patterns
#' @description These scales are based on
#' [scale_linetype][ggplot2::scale_linetype],
#' [scale_linetype_continuous][ggplot2::scale_linetype],
#' [scale_linetype_discrete][ggplot2::scale_linetype] and
#' [scale_linetype_binned][ggplot2::scale_linetype].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @seealso [girafe()]
#' @export
#' @name scale_linetype_interactive
#' @family interactive scale
scale_linetype_interactive <- function(...)
  scale_interactive(scale_linetype, ...)

#' @export
#' @rdname scale_linetype_interactive
scale_linetype_continuous_interactive <- function(...)
  scale_interactive(scale_linetype_continuous, ...)

#' @export
#' @rdname scale_linetype_interactive
scale_linetype_discrete_interactive <- function(...)
  scale_interactive(scale_linetype_discrete, ...)

#' @export
#' @rdname scale_linetype_interactive
scale_linetype_binned_interactive <- function(...)
  scale_interactive(scale_linetype_binned, ...)
