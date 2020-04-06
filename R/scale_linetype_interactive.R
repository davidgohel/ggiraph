#' @title Create interactive scales for line patterns
#' @description These scales are based on
#' \code{\link[ggplot2]{scale_linetype}},
#' \code{\link[ggplot2]{scale_linetype_continuous}},
#' \code{\link[ggplot2]{scale_linetype_discrete}} and
#' \code{\link[ggplot2]{scale_linetype_binned}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the \code{\link{interactive_parameters}}.
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @seealso \code{\link{girafe}}
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
