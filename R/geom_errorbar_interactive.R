#' @rdname geom_crossbar_interactive
#' @export
geom_errorbar_interactive <- function(...) {
  layer_interactive(geom_errorbar, ...)
}


#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveErrorbar <- ggproto(
  "GeomInteractiveErrorbar",
  GeomErrorbar,
  default_aes = add_default_interactive_aes(GeomErrorbar),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    lineend = "butt",
    width = NULL,
    flipped_aes = FALSE,
    .ipar = IPAR_NAMES
  ) {
    data <- flip_data(data, flipped_aes)

    x <- vec_interleave(
      data$xmin,
      data$xmax,
      NA,
      data$x,
      data$x,
      NA,
      data$xmin,
      data$xmax
    )
    y <- vec_interleave(
      data$ymax,
      data$ymax,
      NA,
      data$ymax,
      data$ymin,
      NA,
      data$ymin,
      data$ymin
    )
    data <- data_frame0(
      x = x,
      y = y,
      colour = rep(data$colour, each = 8),
      alpha = rep(data$alpha, each = 8),
      linewidth = rep(data$linewidth, each = 8),
      linetype = rep(data$linetype, each = 8),
      group = rep(seq_len(nrow(data)), each = 8),
      .size = nrow(data) * 8
    )
    data <- flip_data(data, flipped_aes)
    z <- copy_interactive_attrs(data, data, each = 8, ipar = .ipar)
    GeomInteractivePath$draw_panel(
      z,
      panel_params,
      coord,
      lineend = lineend,
      .ipar = .ipar
    )
  }
)
