#' @title Create interactive reference lines
#'
#' @description
#' These geometries are based on [geom_abline()],
#' [geom_hline()] and [geom_vline()].
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add diagonal interactive reference lines to a ggplot -------
#' @example examples/geom_abline_interactive.R
#' @seealso [girafe()]
#' @export
geom_abline_interactive <- function(...)
  layer_interactive(geom_abline, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveAbline <- ggproto(
  "GeomInteractiveAbline",
  GeomAbline,
  default_aes = add_default_interactive_aes(GeomAbline),
  draw_key = function(data, params, size) {
    gr <- GeomAbline$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord) {
    ranges <- coord$backtransform_range(panel_params)

    data$x    <- ranges$x[1]
    data$xend <- ranges$x[2]
    data$y    <- ranges$x[1] * data$slope + data$intercept
    data$yend <- ranges$x[2] * data$slope + data$intercept

    GeomInteractiveSegment$draw_panel(unique(data), panel_params, coord)
  }
)
