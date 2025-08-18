#' @title Create interactive scales for line patterns
#' @description These scales are based on
#' [ggplot2::scale_linetype()],
#' [ggplot2::scale_linetype_continuous()],
#' [ggplot2::scale_linetype_discrete()] and
#' [ggplot2::scale_linetype_binned()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @seealso [girafe()]
#' @export
#' @name scale_linetype_interactive
#' @family interactive scale
scale_linetype_interactive <- function(...) {
  scale_interactive(scale_linetype, ...)
}

#' @export
#' @rdname scale_linetype_interactive
scale_linetype_continuous_interactive <- function(...) {
  scale_interactive(scale_linetype_continuous, ...)
}

#' @export
#' @rdname scale_linetype_interactive
scale_linetype_discrete_interactive <- function(...) {
  scale_interactive(scale_linetype_discrete, ...)
}

#' @export
#' @rdname scale_linetype_interactive
scale_linetype_binned_interactive <- function(...) {
  scale_interactive(scale_linetype_binned, ...)
}
