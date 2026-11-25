#' @title Create interactive smoothed conditional means
#'
#' @description
#' The geometry is based on [ggplot2::geom_smooth()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive bar -------
#' @example examples/geom_smooth_interactive.R
#' @seealso [girafe()]
#' @export
geom_smooth_interactive <- function(...) {
  layer_interactive(geom_smooth, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveSmooth <- ggproto(
  "GeomInteractiveSmooth",
  GeomSmooth,
  default_aes = add_default_interactive_aes(GeomSmooth),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    grobs <- GeomSmooth$draw_group(data, panel_params, coord, ...)
    # the confidence band (when drawn), then the line
    n <- length(grobs)
    if (n > 1) {
      grobs[[1]] <- ribbon_add_interactive_attrs(grobs[[1]], data, ipar = .ipar)
    }
    ia <- get_interactive_attr_names(data, ipar = .ipar)
    aes <- lapply(data[names(data) %in% ia], unique0)
    grobs[[n]] <- add_interactive_attrs(grobs[[n]], aes, ipar = .ipar)
    grobs
  }
)
