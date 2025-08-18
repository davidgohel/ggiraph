#' Create interactive horizontal error bars
#'
#' @description
#' This geometry is based on [ggplot2::geom_errorbarh()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add horizontal error bars -------
#' @example examples/geom_errorbarh_interactive.R
#' @seealso [girafe()]
#' @export
geom_errorbarh_interactive <- function(...) {
  layer_interactive(geom_errorbarh, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @importFrom vctrs vec_interleave
GeomInteractiveErrorbarh <- ggproto(
  "GeomInteractiveErrorbarh",
  GeomErrorbarh,
  default_aes = add_default_interactive_aes(GeomErrorbarh),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    height = NULL,
    lineend = "butt",
    .ipar = IPAR_NAMES
  ) {
    x = vec_interleave(
      data$xmax,
      data$xmax,
      NA,
      data$xmax,
      data$xmin,
      NA,
      data$xmin,
      data$xmin
    )
    y = vec_interleave(
      data$ymin,
      data$ymax,
      NA,
      data$y,
      data$y,
      NA,
      data$ymin,
      data$ymax
    )
    z <- data_frame0(
      x = x,
      y = y,
      colour = rep(data$colour, each = 8),
      alpha = rep(data$alpha, each = 8),
      linewidth = rep(data$linewidth, each = 8),
      linetype = rep(data$linetype, each = 8),
      group = rep(1:(nrow(data)), each = 8),
      .size = nrow(data) * 8
    )
    z <- copy_interactive_attrs(data, z, each = 8, ipar = .ipar)
    GeomInteractivePath$draw_panel(
      z,
      panel_params,
      coord,
      lineend = lineend,
      .ipar = .ipar
    )
  }
)
