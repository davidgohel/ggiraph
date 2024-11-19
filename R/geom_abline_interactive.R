#' @title Create interactive reference lines
#'
#' @description
#' These geometries are based on [ggplot2::geom_abline()],
#' [ggplot2::geom_hline()] and [ggplot2::geom_vline()].
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add diagonal interactive reference lines to a ggplot -------
#' @example examples/geom_abline_interactive.R
#' @seealso [girafe()]
#' @export
geom_abline_interactive <- function(...)
  layer_interactive(geom_abline, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveAbline <- ggproto(
  "GeomInteractiveAbline",
  GeomAbline,
  default_aes = add_default_interactive_aes(GeomAbline),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, lineend = "butt", ..., .ipar = IPAR_NAMES) {
    ranges <- coord$backtransform_range(panel_params)

    if (coord$clip == "on" && coord$is_linear()) {
      # Ensure the line extends well outside the panel to avoid visible line
      # ending for thick lines
      ranges$x <- ranges$x + c(-1, 1) * diff(ranges$x)
    }

    data$x    <- ranges$x[1]
    data$xend <- ranges$x[2]
    data$y    <- ranges$x[1] * data$slope + data$intercept
    data$yend <- ranges$x[2] * data$slope + data$intercept

    GeomInteractiveSegment$draw_panel(unique0(data), panel_params, coord, lineend = lineend, ..., .ipar = .ipar)
  }
)
