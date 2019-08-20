#' @title interactive ribbons and area plots
#'
#' @description
#' The geometries are based on \code{\link[ggplot2]{geom_ribbon}}
#' and \code{\link[ggplot2]{geom_area}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add interactive bar -------
#' @example examples/geom_ribbon_interactive.R
#' @seealso \code{\link{girafe}}
#' @export
geom_ribbon_interactive <- function(...) {
  layer_interactive(geom_ribbon, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveRibbon <- ggproto(
  "GeomInteractiveRibbon",
  GeomRibbon,
  default_aes = add_default_interactive_aes(GeomRibbon),
  draw_key = function(data, params, size) {
    gr <- GeomRibbon$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_group = function(data, panel_params, coord, na.rm = FALSE) {
    if (na.rm) data <- data[stats::complete.cases(data[c("x", "ymin", "ymax")]), ]
    data <- data[order(data$group), ]

    # Check that aesthetics are constant
    ia <- get_interactive_attr_names(data)
    cols <- c("colour", "fill", "size", "linetype", "alpha", ia)
    aes <- unique(data[cols])
    if (nrow(aes) > 1) {
      stop("Aesthetics can not vary with a ribbon")
    }
    aes <- as.list(aes)
    aes <- force_interactive_aes_to_char(aes)

    # Instead of removing NA values from the data and plotting a single
    # polygon, we want to "stop" plotting the polygon whenever we're
    # missing values and "start" a new polygon as soon as we have new
    # values.  We do this by creating an id vector for polygonGrob that
    # has distinct polygon numbers for sequences of non-NA values and NA
    # for NA values in the original data.  Example: c(NA, 2, 2, 2, NA, NA,
    # 4, 4, 4, NA)
    missing_pos <- !stats::complete.cases(data[c("x", "ymin", "ymax")])
    ids <- cumsum(missing_pos) + 1
    ids[missing_pos] <- NA

    data <- unclass(data) #for faster indexing
    positions <- new_data_frame(list(
      x = c(data$x, rev(data$x)),
      y = c(data$ymax, rev(data$ymin)),
      id = c(ids, rev(ids))
    ))
    munched <- coord_munch(coord, positions, panel_params)

    gr <- ggname("geom_ribbon", polygonGrob(
      munched$x, munched$y, id = munched$id,
      default.units = "native",
      gp = gpar(
        fill = alpha(aes$fill, aes$alpha),
        col = aes$colour,
        lwd = aes$size * .pt,
        lty = aes$linetype)
    ))
    add_interactive_attrs(gr, aes)
  }
)

#' @rdname geom_ribbon_interactive
#' @export
geom_area_interactive <- function(...) {
  layer_interactive(geom_area, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveArea <- ggproto(
  "GeomInteractiveArea",
  GeomArea,
  default_aes = add_default_interactive_aes(GeomArea),
  draw_key = function(data, params, size) {
    gr <- GeomArea$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_group = function(data, panel_params, coord, na.rm = FALSE) {
    GeomInteractiveRibbon$draw_group(data, panel_params, coord, na.rm = na.rm)
  }
)
