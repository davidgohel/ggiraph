#' @rdname geom_text_interactive
#' @examples
#' # add interactive labels to a ggplot -------
#' @example examples/geom_label_interactive.R
#' @export
geom_label_interactive <- function(...)
  layer_interactive(geom_label, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveLabel <- ggproto(
  "GeomInteractiveLabel",
  GeomLabel,
  default_aes = add_default_interactive_aes(GeomLabel),
  draw_key = function(data, params, size) {
    gr <- GeomLabel$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(self,
                        data,
                        panel_params,
                        coord,
                        parse = FALSE,
                        na.rm = FALSE,
                        label.padding = unit(0.25, "lines"),
                        label.r = unit(0.15, "lines"),
                        label.size = 0.25) {
    gr <- GeomLabel$draw_panel(
      data,
      panel_params,
      coord,
      parse = parse,
      na.rm = na.rm,
      label.padding = label.padding,
      label.r = label.r,
      label.size = label.size
    )
    coords <- coord$transform(data, panel_params)
    if (is.null(coords$tooltip_fill)) {
      coords$tooltip_fill <- coords$fill
    }
    coords <- force_interactive_aes_to_char(coords)
    add_interactive_attrs(gr, coords)
  }
)
