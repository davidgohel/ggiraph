#' @title Create interactive rectangles
#'
#' @description
#' These geometries are based on [ggplot2::geom_rect()] and [ggplot2::geom_tile()].
#' See the documentation for those functions for more details.
#'
#' @note
#' Converting a raster to svg elements could inflate dramatically the size of the
#' svg and make it unreadable in a browser.
#' Function `geom_tile_interactive` should be used with caution, total number of
#' rectangles should be small.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_rect_interactive.R
#' @seealso [girafe()]
#' @export
geom_rect_interactive <- function(...) {
  layer_interactive(geom_rect, ...)
}

#' @importFrom vctrs vec_cbind
#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @include geom_polygon_interactive.R
GeomInteractiveRect <- ggproto(
  "GeomInteractiveRect",
  GeomRect,
  default_aes = add_default_interactive_aes(GeomRect),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    lineend = "butt",
    linejoin = "mitre",
    .ipar = IPAR_NAMES
  ) {
    if (!coord$is_linear()) {
      aesthetics <- setdiff(
        names(data),
        c("x", "y", "xmin", "xmax", "ymin", "ymax")
      )

      # as in ggplot2 4.0: one polygon of 4 corners per rectangle, closed by
      # the polygon geom
      index <- rep(seq_len(nrow(data)), each = 4)
      new <- data[index, aesthetics, drop = FALSE]
      new$x <- vec_interleave(data$xmin, data$xmax, data$xmax, data$xmin)
      new$y <- vec_interleave(data$ymax, data$ymax, data$ymin, data$ymin)
      new$group <- index

      ggname(
        "geom_rect_interactive",
        GeomInteractivePolygon$draw_panel(
          new,
          panel_params,
          coord,
          lineend = lineend,
          linejoin = linejoin,
          .ipar = .ipar
        )
      )
    } else {
      coords <- coord$transform(data, panel_params)

      gr <- ggname(
        "geom_rect_interactive",
        rectGrob(
          coords$xmin,
          coords$ymax,
          width = coords$xmax - coords$xmin,
          height = coords$ymax - coords$ymin,
          default.units = "native",
          just = c("left", "top"),
          gp = gpar(
            col = coords$colour,
            fill = fill_alpha(coords$fill, coords$alpha),
            lwd = coords$linewidth * .pt,
            lty = coords$linetype,
            linejoin = linejoin,
            lineend = lineend
          )
        )
      )
      add_interactive_attrs(gr, coords, ipar = .ipar)
    }
  }
)
