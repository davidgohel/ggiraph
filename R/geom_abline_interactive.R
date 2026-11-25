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
geom_abline_interactive <- function(...) {
  layer_interactive(geom_abline, ...)
}

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
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    gr <- GeomAbline$draw_panel(data, panel_params, coord, ...)
    # 'ggplot2' draws the unique rows; the computed ends depend on the
    # other columns, so the unique rows are the same before computing them
    add_interactive_attrs(gr, segment_drawn_data(unique0(data)), ipar = .ipar, by_shape = TRUE)
  }
)
