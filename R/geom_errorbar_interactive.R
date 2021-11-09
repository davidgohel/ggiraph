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
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data,
                        panel_params,
                        coord,
                        width = NULL,
                        flipped_aes = FALSE,
                        .ipar = IPAR_NAMES) {
    data <- flip_data(data, flipped_aes)

    # because of errors when there are NA's or in facets when we use fill,
    # it's safer to draw each bar separately
    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]

      box <- new_data_frame(
        list(
          x = as.vector(rbind(
            row$xmin,
            row$xmax,
            NA,
            row$x,
            row$x,
            NA,
            row$xmin,
            row$xmax
          )),
          y = as.vector(rbind(
            row$ymax,
            row$ymax,
            NA,
            row$ymax,
            row$ymin,
            NA,
            row$ymin,
            row$ymin
          )),
          colour = rep(row$colour, each = 8),
          alpha = rep(row$alpha, each = 8),
          size = rep(row$size, each = 8),
          linetype = rep(row$linetype, each = 8),
          group = rep(1:(nrow(row)), each = 8),
          row.names = 1:(nrow(row) * 8)
        )
      )
      box <- copy_interactive_attrs(row, box, each = 8, ipar = .ipar)
      box <- flip_data(box, flipped_aes)
      GeomInteractivePath$draw_panel(box, panel_params, coord, .ipar = .ipar)
    })
    grobTree(do.call(gList, grobs))
  }
)
