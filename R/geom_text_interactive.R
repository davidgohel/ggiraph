#' @title interactive textual annotations.
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_text}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_text_interactive.R
#' @seealso \code{\link{girafe}}
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
