#' @rdname geom_crossbar_interactive
#' @export
geom_linerange_interactive <- function(...)
  layer_interactive(geom_linerange, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveLinerange <- ggproto(
  "GeomInteractiveLinerange",
  GeomLinerange,
  default_aes = add_default_interactive_aes(GeomLinerange),
  draw_key = function(data, params, size) {
    gr <- GeomLinerange$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord, flipped_aes = FALSE) {
    data <- flip_data(data, flipped_aes)
    data <- transform(data,
                      xend = x,
                      y = ymin,
                      yend = ymax)
    data <- flip_data(data, flipped_aes)
    ggname(
      "geom_linerange_interactive",
      GeomInteractiveSegment$draw_panel(data, panel_params, coord)
    )
  }
)
