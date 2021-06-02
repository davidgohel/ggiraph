#' @rdname geom_abline_interactive
#' @examples
#' # add horizontal interactive reference lines to a ggplot -------
#' @example examples/geom_hline_interactive.R
#' @seealso [girafe()]
#' @export
geom_hline_interactive <- function(...)
  layer_interactive(geom_hline, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveHline <- ggproto(
  "GeomInteractiveHline",
  GeomHline,
  default_aes = add_default_interactive_aes(GeomHline),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, .ipar = IPAR_NAMES) {
    ranges <- coord$backtransform_range(panel_params)

    data$x    <- ranges$x[1]
    data$xend <- ranges$x[2]
    data$y    <- data$yintercept
    data$yend <- data$yintercept

    GeomInteractiveSegment$draw_panel(unique(data), panel_params, coord, .ipar = .ipar)
  }
)
