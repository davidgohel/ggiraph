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
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    gr <- GeomLabel$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    if (is.null(coords$tooltip_fill)) {
      coords$tooltip_fill <- coords$fill
    }
    add_interactive_attrs(gr, coords, ipar = .ipar)
  }
)

#' @export
makeContent.interactive_label_grob <- function(x) {
  gr <- NextMethod()
  data <- get_interactive_data(x)
  data_attr <- get_data_attr(x)
  ipar <- get_ipar(x)
  for (i in seq_along(gr$children)) {
    gr$children[[i]] <- add_interactive_attrs(
      gr$children[[i]], data = data, data_attr = data_attr, ipar = ipar
    )
  }
  gr
}
