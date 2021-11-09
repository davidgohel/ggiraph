#' @title Create interactive points grob
#'
#' @description
#' The grob is based on [pointsGrob()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_points_grob <- function(...) {
  grob_interactive(grid::pointsGrob, ...)
}

shapes_with_lines <- c(3, 4, 7, 8, 9, 10, 11, 12, 13, 14)

#' @export
drawDetails.interactive_points_grob <- function(x, recording) {
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
  } else {
    grobs <- list(x)
  }
  purrr::walk(grobs, function(x) {
    dsvg_tracer_on()
    class(x) <- class(x)[-1]
    grid::drawDetails(x, recording)
    ids <- dsvg_tracer_off()
    interactive_attr_toxml(x = x, ids = ids)
  })
  invisible()
}

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
