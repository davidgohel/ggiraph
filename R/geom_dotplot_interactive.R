#' @title Create interactive dot plots
#'
#' @description
#' This geometry is based on [geom_dotplot()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
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
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    zz <- GeomDotplot$draw_group(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    add_interactive_attrs(zz, coords, ipar = .ipar)
  }
)

#' @export
#' @importFrom grid makeContext
makeContext.interactive_dotstack_grob <- function(x) {
  gr <- NextMethod()
  add_interactive_attrs(
    gr,
    data = get_interactive_data(x),
    data_attr = get_data_attr(x),
    ipar = get_ipar(x)
  )
}
