#' @rdname geom_crossbar_interactive
#' @export
geom_pointrange_interactive <- function(...)
  layer_interactive(geom_pointrange, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractivePointrange <- ggproto(
  "GeomInteractivePointrange",
  GeomPointrange,
  default_aes = add_default_interactive_aes(GeomPointrange),
  draw_key = function(data, params, size) {
    gr <- GeomPointrange$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord, fatten = 4) {
    if (is.null(data$y))
      return(GeomInteractiveLinerange$draw_panel(data, panel_params, coord))

    ggname("geom_pointrange", gTree(
      children = gList(
        GeomInteractiveLinerange$draw_panel(data, panel_params, coord),
        GeomInteractivePoint$draw_panel(transform(data, size = size * fatten), panel_params, coord)
      )
    ))
  }
)
