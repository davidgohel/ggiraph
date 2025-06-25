#' @title Create interactive scales for alpha transparency
#' @description These scales are based on
#' [ggplot2::scale_alpha()],
#' [ggplot2::scale_alpha_continuous()],
#' [ggplot2::scale_alpha_discrete()],
#' [ggplot2::scale_alpha_binned()],
#' [ggplot2::scale_alpha_ordinal()],
#' [ggplot2::scale_alpha_date()],
#' [ggplot2::scale_alpha_datetime()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @seealso [girafe()]
#' @export
#' @name scale_alpha_interactive
#' @family interactive scale
scale_alpha_interactive <- function(...) {
  scale_interactive(scale_alpha, ...)
}

#' @export
#' @rdname scale_alpha_interactive
scale_alpha_continuous_interactive <- function(...) {
  scale_interactive(scale_alpha_continuous, ...)
}

#' @export
#' @rdname scale_alpha_interactive
scale_alpha_discrete_interactive <- function(...) {
  scale_interactive(scale_alpha_discrete, ...)
}

#' @export
#' @rdname scale_alpha_interactive
scale_alpha_binned_interactive <- function(...) {
  scale_interactive(scale_alpha_binned, ...)
}

#' @export
#' @rdname scale_alpha_interactive
scale_alpha_ordinal_interactive <- function(...) {
  scale_interactive(scale_alpha_ordinal, ...)
}

#' @export
#' @rdname scale_alpha_interactive
scale_alpha_date_interactive <- function(...) {
  scale_interactive(scale_alpha_date, ...)
}

#' @export
#' @rdname scale_alpha_interactive
scale_alpha_datetime_interactive <- function(...) {
  scale_interactive(scale_alpha_datetime, ...)
}
