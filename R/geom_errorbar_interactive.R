#' @rdname geom_crossbar_interactive
#' @export
geom_errorbar_interactive <- function(...)
  layer_interactive(geom_errorbar, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveErrorbar <- ggproto(
  "GeomInteractiveErrorbar",
  GeomErrorbar,
  default_aes = add_default_interactive_aes(GeomErrorbar),
  draw_key = function(data, params, size) {
    gr <- GeomErrorbar$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data,
                        panel_params,
                        coord,
                        width = NULL,
                        flipped_aes = FALSE) {
    data <- flip_data(data, flipped_aes)
    x <- as.vector(rbind(
      data$xmin,
      data$xmax,
      NA,
      data$x,
      data$x,
      NA,
      data$xmin,
      data$xmax
    ))
    y <- as.vector(rbind(
      data$ymax,
      data$ymax,
      NA,
      data$ymax,
      data$ymin,
      NA,
      data$ymin,
      data$ymin
    ))
    box <- new_data_frame(
      list(
        x = x,
        y = y,
        colour = rep(data$colour, each = 8),
        alpha = rep(data$alpha, each = 8),
        size = rep(data$size, each = 8),
        linetype = rep(data$linetype, each = 8),
        group = rep(1:(nrow(data)), each = 8),
        row.names = 1:(nrow(data) * 8)
      )
    )
    box <- copy_interactive_attrs(data, box, each = 8)
    box <- flip_data(box, flipped_aes)
    GeomInteractivePath$draw_panel(box, panel_params, coord)
  }
)
