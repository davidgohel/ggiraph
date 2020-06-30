#' @title Create interactive textual annotations
#'
#' @description
#' The geometries are based on [geom_text()] and [geom_label()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive texts to a ggplot -------
#' @example examples/geom_text_interactive.R
#' @seealso [girafe()]
#' @export
geom_text_interactive <- function(...)
  layer_interactive(geom_text, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveText <- ggproto(
  "GeomInteractiveText",
  GeomText,
  default_aes = add_default_interactive_aes(GeomText),
  draw_key = function(data, params, size) {
    gr <- GeomText$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data,
                        panel_params,
                        coord,
                        parse = FALSE,
                        na.rm = FALSE,
                        check_overlap = FALSE) {
    zz <- GeomText$draw_panel(
      data,
      panel_params,
      coord,
      parse = parse,
      na.rm = na.rm,
      check_overlap = check_overlap
    )
    coords <- coord$transform(data, panel_params)
    coords <- force_interactive_aes_to_char(coords)
    add_interactive_attrs(zz, coords)
  }
)
