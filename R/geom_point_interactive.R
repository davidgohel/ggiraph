#' @title Create interactive points
#'
#' @description
#' The geometry is based on [ggplot2::geom_point()].
#' See the documentation for those functions for more details.
#'
#' @note
#' The following shapes id 3, 4 and 7 to 14 are composite symbols and should not be used.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive points to a ggplot -------
#' @example examples/geom_point_interactive.R
#' @seealso [girafe()]
#' @export
geom_point_interactive <- function(...) {
  layer_interactive(geom_point, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractivePoint <- ggproto(
  "GeomInteractivePoint",
  GeomPoint,
  default_aes = add_default_interactive_aes(GeomPoint),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    ...,
    .ipar = IPAR_NAMES
  ) {
    zz <- GeomPoint$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    x <- add_interactive_attrs(zz, coords, ipar = .ipar)

    shapes <- unique(x$pch)
    shape_index <- shapes %in% shapes_with_lines

    if (length(shapes) > 1 && any(shape_index)) {
      # if some shapes contain lines, split the grob to multiple ones:
      # one grob for all points without these shapes and then
      # a grob for each different shape
      shapes_with_lines_present <- intersect(shapes, shapes_with_lines)
      grobs <- lapply(c(NA, shapes_with_lines_present), function(shape) {
        partialPointGrob(x, pch = shape)
      })
      gTree(children = do.call(gList, grobs))
    } else {
      x
    }
  }
)

shapes_with_lines <- c(3, 4, 7, 8, 9, 10, 11, 12, 13, 14)

partialPointGrob <- function(gr, pch = NA) {
  if (is.na(pch)) {
    index <- !(gr$pch %in% shapes_with_lines)
  } else {
    index <- gr$pch %in% pch
  }
  if (!any(index)) {
    return(zeroGrob())
  }
  gr$name <- paste0(gr$name, ".", pch)
  for (m in c("x", "y", "pch", "size")) {
    if (length(gr[[m]]) > 1) {
      gr[[m]] <- gr[[m]][index]
    }
  }
  for (m in c("col", "fill", "fontsize", "lwd")) {
    if (length(gr$gp[[m]]) > 1) {
      gr$gp[[m]] <- gr$gp[[m]][index]
    }
  }
  ipar <- get_ipar(gr)
  for (m in ipar) {
    if (length(gr$.interactive[[m]]) > 1) {
      gr$.interactive[[m]] <- gr$.interactive[[m]][index]
    }
  }
  gr
}
