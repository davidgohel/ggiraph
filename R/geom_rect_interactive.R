#' @title interactive rectangles
#'
#' @description
#' These geometries are based on \code{\link[ggplot2]{geom_rect}} and
#' \code{\link[ggplot2]{geom_tile}}.
#' See the documentation for those functions for more details.
#'
#' @note
#' Converting a raster to svg elements could inflate dramatically the size of the
#' svg and make it unreadable in a browser.
#' Function \code{geom_tile_interactive} should be used with caution, total number of
#' rectangles should be small.
#'
#' @seealso \code{\link{girafe}}
#' @inheritParams ggplot2::geom_rect
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_rect_interactive.R
#' @export
geom_rect_interactive <- function(mapping = NULL, data = NULL,
                                  stat = "identity", position = "identity",
                                  ...,
                                  linejoin = "mitre",
                                  na.rm = FALSE,
                                  show.legend = NA,
                                  inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomInteractiveRect,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      linejoin = linejoin,
      na.rm = na.rm,
      ...
    )
  )
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @include geom_polygon_interactive.R
GeomInteractiveRect <- ggproto("GeomInteractiveRect", Geom,
		default_aes = aes(colour = NA, fill = "grey20",
		                  size = 0.5, linetype = 1, alpha = NA,
		                  tooltip = NULL, onclick = NULL, data_id = NULL),

		required_aes = c("xmin", "xmax", "ymin", "ymax"),

		draw_panel = function(self, data, panel_scales, coord, linejoin = "mitre") {
			if (!coord$is_linear()) {
				aesthetics <- setdiff(
						names(data), c("x", "y", "xmin", "xmax", "ymin", "ymax")
				)

        polys <- lapply(split(data, seq_len(nrow(data)) ), function(row) {
          poly <- rect_to_poly(row$xmin, row$xmax, row$ymin, row$ymax)
          aes <- as.data.frame(row[aesthetics],
                               stringsAsFactors = FALSE)[rep(1,5), ]

          GeomInteractivePolygon$draw_panel(cbind(poly, aes), panel_scales, coord)
        } )

				setGrobName("bar", do.call("grobTree", polys))
			} else {
				coords <- coord$transform(data, panel_scales)

				if( !is.null(coord$tooltip) && !is.character(coord$tooltip) )
				  coord$tooltip <- as.character(coord$tooltip)
				if( !is.null(coord$onclick) && !is.character(coord$onclick) )
				  coord$onclick <- as.character(coord$onclick)
				if( !is.null(coord$data_id) && !is.character(coord$data_id) )
				  coord$data_id <- as.character(coord$data_id)


				setGrobName("geom_rect_interactive", interactive_rect_grob(
								coords$xmin, coords$ymax,
								tooltip = coords$tooltip,
								onclick = coords$onclick,
								data_id = coords$data_id,
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
								  lineend = if (identical(linejoin, "round")) "round" else "square"
								)
						))
			}
		},

		draw_key = draw_key_polygon
)


rect_to_poly <- function(xmin, xmax, ymin, ymax) {
	data.frame(
			y = c(ymax, ymax, ymin, ymin, ymax),
			x = c(xmin, xmax, xmax, xmin, xmin)
	)
}
