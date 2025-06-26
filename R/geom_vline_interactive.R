#' @rdname geom_abline_interactive
#' @examples
#' # add vertical interactive reference lines to a ggplot -------
#' @example examples/geom_vline_interactive.R
#' @seealso [girafe()]
#' @export
geom_vline_interactive <- function(...) {
  layer_interactive(geom_vline, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveVline <- ggproto(
  "GeomInteractiveVline",
  GeomVline,
  default_aes = add_default_interactive_aes(GeomVline),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, .ipar = IPAR_NAMES) {
    ranges <- coord$backtransform_range(panel_params)

    data$x <- data$xintercept
    data$xend <- data$xintercept
    data$y <- ranges$y[1]
    data$yend <- ranges$y[2]

    GeomInteractiveSegment$draw_panel(
      unique(data),
      panel_params,
      coord,
      .ipar = .ipar
    )
  }
)
