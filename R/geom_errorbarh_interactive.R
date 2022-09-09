#' Create interactive horizontal error bars
#'
#' @description
#' This geometry is based on [geom_errorbarh()].
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
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, height = NULL,
                        .ipar = IPAR_NAMES) {

    # because of errors when there are NA's or in facets when we use fill,
    # it's safer to draw each bar separately
    grobs <- lapply(seq_len(nrow(data)), function(i) {
      row <- data[i, , drop = FALSE]

      box <- new_data_frame(
        list(
          x = as.vector(rbind(
            row$xmax,
            row$xmax,
            NA,
            row$xmax,
            row$xmin,
            NA,
            row$xmin,
            row$xmin
          )),
          y = as.vector(rbind(
            row$ymin,
            row$ymax,
            NA,
            row$y,
            row$y,
            NA,
            row$ymin,
            row$ymax
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
      GeomInteractivePath$draw_panel(box, panel_params, coord, .ipar = .ipar)
    })
    grobTree(do.call(gList, grobs))
  }
)
