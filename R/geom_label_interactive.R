#' @rdname geom_text_interactive
#' @examples
#' # add interactive labels to a ggplot -------
#' @example examples/geom_label_interactive.R
#' @export
geom_label_interactive <- function(...) {
  layer_interactive(geom_label, ...)
}

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
    coords <- force_interactive_aes_to_char(coords)
    add_interactive_attrs(gr, coords)
  }
)

#' @export
#' @title interactive_label_grob drawing
#' @description draw an interactive_label_grob
#' @inheritParams grid::makeContent
makeContent.interactive_label_grob <- function(x) {
  hj <- resolveHJust(x$just, NULL)
  vj <- resolveVJust(x$just, NULL)

  t1 <- textGrob(
    x$label,
    x$x + 2 * (0.5 - hj) * x$padding,
    x$y + 2 * (0.5 - vj) * x$padding,
    just = c(hj, vj),
    gp = x$text.gp,
    name = "text"
  )

  t <- textGrob(
    label = x$label,
    x = x$x + 2 * (0.5 - hj) * x$padding,
    y = x$y + 2 * (0.5 - vj) * x$padding,
    just = c(hj, vj),
    check.overlap = FALSE,
    default.units = x$default.units,
    name = "label",
    gp = x$text.gp
  )
  t <- add_interactive_attrs(t, x)

  r <- roundrectGrob(
    x = x$x,
    y = x$y,
    width = grobWidth(t1) + 2 * x$padding,
    height = grobHeight(t1) + 2 * x$padding,
    r = x$r,
    just = c(hj, vj),
    default.units = x$default.units,
    name = "box",
    gp = x$rect.gp
  )
  r <- add_interactive_attrs(r, x)

  setChildren(x, gList(r, t))
}
