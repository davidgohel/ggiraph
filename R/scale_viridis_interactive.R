#' @title Create interactive viridis colour scales
#' @description These scales are based on
#' [ggplot2::scale_colour_viridis_d()],
#' [ggplot2::scale_fill_viridis_d()],
#' [ggplot2::scale_colour_viridis_c()],
#' [ggplot2::scale_fill_viridis_c()],
#' [ggplot2::scale_colour_viridis_b()],
#' [ggplot2::scale_fill_viridis_b()],
#' [ggplot2::scale_colour_ordinal()],
#' [ggplot2::scale_fill_ordinal()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @return An interactive scale object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @examples
#' # add interactive viridis scale to a ggplot -------
#' @example examples/scale_viridis_guide_legend_continuous_interactive.R
#' @seealso [girafe()]
#' @export
#' @name scale_viridis_interactive
#' @family interactive scale
scale_colour_viridis_d_interactive <- function(...) {
  scale_interactive(scale_colour_viridis_d, ...)
}

#' @export
#' @rdname scale_viridis_interactive
scale_color_viridis_d_interactive <- scale_colour_viridis_d_interactive

#' @export
#' @rdname scale_viridis_interactive
scale_fill_viridis_d_interactive <- function(...) {
  scale_interactive(scale_fill_viridis_d, ...)
}

#' @export
#' @rdname scale_viridis_interactive
scale_colour_viridis_c_interactive <- function(...) {
  scale_interactive(scale_colour_viridis_c, ...)
}

#' @export
#' @rdname scale_viridis_interactive
scale_color_viridis_c_interactive <- scale_colour_viridis_c_interactive

#' @export
#' @rdname scale_viridis_interactive
scale_fill_viridis_c_interactive <- function(...) {
  scale_interactive(scale_fill_viridis_c, ...)
}

#' @export
#' @rdname scale_viridis_interactive
scale_colour_viridis_b_interactive <- function(...) {
  scale_interactive(scale_colour_viridis_b, ...)
}

#' @export
#' @rdname scale_viridis_interactive
scale_color_viridis_b_interactive <- scale_colour_viridis_b_interactive

#' @export
#' @rdname scale_viridis_interactive
scale_fill_viridis_b_interactive <- function(...) {
  scale_interactive(scale_fill_viridis_b, ...)
}

#' @export
#' @rdname scale_viridis_interactive
scale_colour_ordinal_interactive <- function(...) {
  scale_interactive(scale_colour_ordinal, ...)
}

#' @export
#' @rdname scale_viridis_interactive
scale_color_ordinal_interactive <- scale_colour_ordinal_interactive

#' @export
#' @rdname scale_viridis_interactive
scale_fill_ordinal_interactive <- function(...) {
  scale_interactive(scale_fill_ordinal, ...)
}
