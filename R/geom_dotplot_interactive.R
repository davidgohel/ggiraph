#' @title Create interactive dot plots
#'
#' @description
#' This geometry is based on [geom_dotplot()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive dot plots to a ggplot -------
#' @example examples/geom_dotplot_interactive.R
#' @seealso [girafe()]
#' @export
geom_dotplot_interactive <- function(...)
  layer_interactive(geom_dotplot, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveDotplot <- ggproto(
  "GeomInteractiveDotplot",
  GeomDotplot,
  default_aes = add_default_interactive_aes(GeomDotplot),
  draw_key = function(data, params, size) {
    gr <- GeomDotplot$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  parameters = function(extra = FALSE) {
    GeomDotplot$parameters(extra = extra)
  },
  draw_group = function(data, panel_params, coord, ...) {
    zz <- GeomDotplot$draw_group(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    add_interactive_attrs(zz, coords)
  }
)

#' @export
makeContext.interactive_dotstack_grob <- function(x, recording = TRUE) {
  gr <- NextMethod()
  gr <- add_interactive_attrs(gr, x)
  gr
}
