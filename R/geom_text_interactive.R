#' @title Create interactive textual annotations
#'
#' @description
#' The geometries are based on [ggplot2::geom_text()] and [ggplot2::geom_label()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive texts to a ggplot -------
#' @example examples/geom_text_interactive.R
#' @seealso [girafe()]
#' @export
geom_text_interactive <- function(...) {
  layer_interactive(geom_text, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveText <- ggproto(
  "GeomInteractiveText",
  GeomText,
  default_aes = add_default_interactive_aes(GeomText),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    zz <- GeomText$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    add_interactive_attrs(zz, coords, ipar = .ipar)
  }
)
