#' Create interactive horizontal error bars
#'
#' @description
#' This geometry is based on [geom_errorbarh()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add horizontal error bars -------
#' @example examples/geom_errorbarh_interactive.R
#' @seealso [girafe()]
#' @export
geom_errorbarh_interactive <- function(...)
  layer_interactive(geom_errorbarh, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveErrorbarh <- ggproto(
  "GeomInteractiveErrorbarh",
  GeomErrorbarh,
  default_aes = add_default_interactive_aes(GeomErrorbarh),
  draw_key = function(data, params, size) {
    gr <- GeomErrorbarh$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data, panel_params, coord, width = NULL) {
    box <- new_data_frame(
      list(
        x = as.vector(
          rbind(
            data$xmax,
            data$xmax,
            NA,
            data$xmax,
            data$xmin,
            NA,
            data$xmin,
            data$xmin
          )
        ),
        y = as.vector(
          rbind(
            data$ymin,
            data$ymax,
            NA,
            data$y,
            data$y,
            NA,
            data$ymin,
            data$ymax
          )
        ),
        colour = rep(data$colour, each = 8),
        alpha = rep(data$alpha, each = 8),
        size = rep(data$size, each = 8),
        linetype = rep(data$linetype, each = 8),
        group = rep(1:(nrow(data)), each = 8),
        row.names = 1:(nrow(data) * 8)
      )
    )
    box <- copy_interactive_attrs(data, box, each = 8)
    GeomInteractivePath$draw_panel(box, panel_params, coord)
  }
)
