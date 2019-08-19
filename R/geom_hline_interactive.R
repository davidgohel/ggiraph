#' @title Horizontal interactive reference line
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_hline}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add interactive reference lines to a ggplot -------
#' @example examples/geom_hline_interactive.R
#' @seealso \code{\link{girafe}}
#' @export
geom_hline_interactive <- function(...) {
  layer_interactive(geom_hline, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveHline <- ggproto(
  "GeomInteractiveHline",
  GeomHline,
  default_aes = add_default_interactive_aes(GeomHline),
  draw_key = function(data, params, size) {
    gr <- GeomHline$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord) {
    ranges <- coord$backtransform_range(panel_params)

    data$x    <- ranges$x[1]
    data$xend <- ranges$x[2]
    data$y    <- data$yintercept
    data$yend <- data$yintercept

    GeomInteractiveSegment$draw_panel(unique(data), panel_params, coord)
  }
)
