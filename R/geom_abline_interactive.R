#' @title interactive reference lines
#'
#' @description
#' These geometries are based on \code{\link[ggplot2]{geom_abline}},
#' \code{\link[ggplot2]{geom_hline}} and \code{\link[ggplot2]{geom_vline}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add diagonal interactive reference lines to a ggplot -------
#' @example examples/geom_abline_interactive.R
#' @seealso \code{\link{girafe}}
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
  draw_key = function(data, params, size) {
    gr <- GeomAbline$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord) {
    ranges <- coord$backtransform_range(panel_params)

    data$x    <- ranges$x[1]
    data$xend <- ranges$x[2]
    data$y    <- ranges$x[1] * data$slope + data$intercept
    data$yend <- ranges$x[2] * data$slope + data$intercept

    GeomInteractiveSegment$draw_panel(unique(data), panel_params, coord)
  }
)
