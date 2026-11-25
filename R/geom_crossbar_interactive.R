#' Create interactive vertical intervals: lines, crossbars & errorbars
#'
#' @description
#' These geometries are based on [ggplot2::geom_crossbar()], [ggplot2::geom_errorbar()],
#' [ggplot2::geom_linerange()] and [ggplot2::geom_pointrange()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive intervals -------
#' @example examples/geom_crossbar_interactive.R
#' @seealso [girafe()]
#' @export
geom_crossbar_interactive <- function(...) {
  layer_interactive(geom_crossbar, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveCrossbar <- ggproto(
  "GeomInteractiveCrossbar",
  GeomCrossbar,
  default_aes = add_default_interactive_aes(GeomCrossbar),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    ...,
    middle_gp = NULL,
    .ipar = IPAR_NAMES
  ) {
    gr <- GeomCrossbar$draw_panel(
      data,
      panel_params,
      coord,
      ...,
      middle_gp = middle_gp
    )
    crossbar_add_interactive_attrs(gr, data, middle_gp = middle_gp, ipar = .ipar)
  }
)

#' Set the interactive attributes of a crossbar drawn by
#' `GeomCrossbar$draw_panel()`
#' @details
#' 'ggplot2' returns a tree with the boxes (a polygon, one shape per row)
#' and the middle lines (segments). The middle lines take the linetype and
#' linewidth of `middle_gp` before the rows removed by `GeomSegment` are
#' dropped. Also used by `GeomInteractiveBoxplot` for its box.
#' @noRd
crossbar_add_interactive_attrs <- function(
  gr,
  data,
  middle_gp = NULL,
  ipar = IPAR_NAMES
) {
  gr$children[[1]] <- add_interactive_attrs(
    gr$children[[1]],
    data,
    ipar = ipar,
    by_shape = TRUE
  )
  middle <- data
  middle$linetype <- middle_gp$linetype %||% middle$linetype
  middle$linewidth <- middle_gp$linewidth %||% middle$linewidth
  gr$children[[2]] <- add_interactive_attrs(
    gr$children[[2]],
    segment_drawn_data(middle),
    ipar = ipar,
    by_shape = TRUE
  )
  gr
}
