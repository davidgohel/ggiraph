#' @rdname geom_text_interactive
#' @examples
#' # add interactive labels to a ggplot -------
#' @example examples/geom_label_interactive.R
#' @export
geom_label_interactive <- function(...)
  layer_interactive(geom_label, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveLabel <- ggproto(
  "GeomInteractiveLabel",
  GeomLabel,
  default_aes = add_default_interactive_aes(GeomLabel),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    gr <- GeomLabel$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    if (is.null(coords$tooltip_fill)) {
      coords$tooltip_fill <- coords$fill
    }
    for (i in seq_along(gr$children)) {
      for (j in seq_along(gr$children[[i]]$children)) {
        if (inherits(gr$children[[i]]$children[[j]], "roundrect")) {
          gr$children[[i]]$children[[j]] <- add_interactive_attrs(
            gr$children[[i]]$children[[j]],
            data = coords[i, ], ipar = .ipar
          )
        } else if (inherits(gr$children[[i]]$children[[j]], "titleGrob")) {
          gr$children[[i]]$children[[j]]$children[[1]] <- add_interactive_attrs(
            gr$children[[i]]$children[[j]]$children[[1]],
            data = coords[i, ], ipar = .ipar
          )
        }
      }
    }
    gr
  }
)
