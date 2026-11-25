#' @title Create interactive scales for line width
#' @description These scales are based on
#' [ggplot2::scale_linewidth()],
#' [ggplot2::scale_linewidth_continuous()],
#' [ggplot2::scale_linewidth_discrete()],
#' [ggplot2::scale_linewidth_binned()],
#' [ggplot2::scale_linewidth_date()],
#' [ggplot2::scale_linewidth_datetime()] and
#' [ggplot2::scale_linewidth_ordinal()].
#' See the documentation for those functions for more details.
#'
#' The legend keys are interactive when the layer uses an interactive geom
#' (e.g. [geom_line_interactive()]).
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @examples
#' library(ggplot2)
#' dat <- data.frame(
#'   x = rep(1:5, 3),
#'   y = c(1:5, 2:6, 3:7),
#'   width = rep(c(1, 2, 3), each = 5)
#' )
#' p <- ggplot(dat, aes(x, y, group = width, linewidth = width)) +
#'   geom_line_interactive(aes(data_id = width, tooltip = width)) +
#'   scale_linewidth_interactive(
#'     data_id = function(breaks) as.character(breaks),
#'     tooltip = function(breaks) paste("width:", breaks)
#'   )
#' x <- girafe(ggobj = p)
#' if (interactive()) print(x)
#' @seealso [girafe()]
#' @export
#' @name scale_linewidth_interactive
#' @family interactive scale
scale_linewidth_interactive <- function(...) {
  scale_interactive(scale_linewidth, ...)
}

#' @export
#' @rdname scale_linewidth_interactive
scale_linewidth_continuous_interactive <- function(...) {
  scale_interactive(scale_linewidth_continuous, ...)
}

#' @export
#' @rdname scale_linewidth_interactive
scale_linewidth_discrete_interactive <- function(...) {
  scale_interactive(scale_linewidth_discrete, ...)
}

#' @export
#' @rdname scale_linewidth_interactive
scale_linewidth_binned_interactive <- function(...) {
  scale_interactive(scale_linewidth_binned, ...)
}

#' @export
#' @rdname scale_linewidth_interactive
scale_linewidth_date_interactive <- function(...) {
  scale_interactive(scale_linewidth_date, ...)
}

#' @export
#' @rdname scale_linewidth_interactive
scale_linewidth_datetime_interactive <- function(...) {
  scale_interactive(scale_linewidth_datetime, ...)
}

#' @export
#' @rdname scale_linewidth_interactive
scale_linewidth_ordinal_interactive <- function(...) {
  scale_interactive(scale_linewidth_ordinal, ...)
}
