#' @title Create interactive rectangles
#'
#' @description
#' These geometries are based on [geom_rect()] and [geom_tile()].
#' See the documentation for those functions for more details.
#'
#' @note
#' Converting a raster to svg elements could inflate dramatically the size of the
#' svg and make it unreadable in a browser.
#' Function \code{geom_tile_interactive} should be used with caution, total number of
#' rectangles should be small.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_rect_interactive.R
#' @seealso [girafe()]
#' @export
geom_rect_interactive <- function(...)
  layer_interactive(geom_rect, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @include geom_polygon_interactive.R
GeomInteractiveRect <- ggproto(
  "GeomInteractiveRect",
  GeomRect,
  default_aes = add_default_interactive_aes(GeomRect),
  draw_key = function(data, params, size) {
    gr <- GeomRect$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(self, data, panel_params, coord, linejoin = "mitre") {
    if (!coord$is_linear()) {
      aesthetics <- setdiff(names(data),
                            c("x", "y", "xmin", "xmax", "ymin", "ymax"))

      polys <-
        lapply(split(data, seq_len(nrow(data))), function(row) {
          poly <- rect_to_poly(row$xmin, row$xmax, row$ymin, row$ymax)
          aes <- new_data_frame(row[aesthetics])[rep(1, 5), ]

          GeomInteractivePolygon$draw_panel(cbind(poly, aes), panel_params, coord)
        })

      ggname("bar", do.call("grobTree", polys))
    } else {
      coords <- coord$transform(data, panel_params)
      coords <- force_interactive_aes_to_char(coords)

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
            fill = alpha(coords$fill, coords$alpha),
            lwd = coords$size * .pt,
            lty = coords$linetype,
            linejoin = linejoin,
            # `lineend` is a workaround for Windows and intentionally kept unexposed
            # as an argument. (c.f. https://github.com/tidyverse/ggplot2/issues/3037#issuecomment-457504667)
            lineend = if (identical(linejoin, "round"))
              "round"
            else
              "square"
          )
        )
      )
      add_interactive_attrs(gr, coords)
    }
  }
)

rect_to_poly <- function(xmin, xmax, ymin, ymax) {
  new_data_frame(list(
    y = c(ymax, ymax, ymin, ymin, ymax),
    x = c(xmin, xmax, xmax, xmin, xmin)
  ))
}
