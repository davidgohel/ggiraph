#' @rdname geom_abline_interactive
#' @examples
#' # add vertical interactive reference lines to a ggplot -------
#' @example examples/geom_vline_interactive.R
#' @seealso [girafe()]
#' @export
geom_vline_interactive <- function(...)
  layer_interactive(geom_vline, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveVline <- ggproto(
  "GeomInteractiveVline",
  GeomVline,
  default_aes = add_default_interactive_aes(GeomVline),
  draw_key = function(data, params, size) {
    gr <- GeomVline$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord) {
    ranges <- coord$backtransform_range(panel_params)

    data$x    <- data$xintercept
    data$xend <- data$xintercept
    data$y    <- ranges$y[1]
    data$yend <- ranges$y[2]

    GeomInteractiveSegment$draw_panel(unique(data), panel_params, coord)
  }
)
