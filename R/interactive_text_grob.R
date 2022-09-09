#' @title Create interactive text grob
#'
#' @description
#' The grob is based on [textGrob][grid::grid.text].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_text_grob <- function(...) {
  grob_interactive(grid::textGrob, ...)
}

#' @export
drawDetails.interactive_text_grob <- function(x, recording) {
  dsvg_tracer_on()
  NextMethod()
  ids <- dsvg_tracer_off()
  rows <- NULL
  n <- max(length(x$x), length(x$y), length(x$label), length(ids))
  if (x$check.overlap && n > 1) {
    rows <- get_non_overlapping_rows(x)
  }
  interactive_attr_toxml(x = x, ids = ids, rows = rows)
  invisible()
}

get_non_overlapping_rows <- function(gr) {
  rows <- NULL
  if (length(dev.list()) > 0 && .Device == "dsvg_device") {
    result <- non_overlapping_texts(
      dn = as.integer(dev.cur() - 1L),
      label = gr$label,
      x = grid::convertX(gr$x, "inches", valueOnly = TRUE),
      y = grid::convertY(gr$y, "inches", valueOnly = TRUE),
      hjust = as.double(grid::resolveHJust(gr$just, gr$hjust)),
      vjust = as.double(grid::resolveVJust(gr$just, gr$vjust)),
      rot = as.double(gr$rot %||% double(0)),
      fontsize = as.double(gr$gp$fontsize %||% double(0)),
      fontfamily = as.character(gr$gp$fontfamily %||% character(0)),
      fontface = as.integer(gr$gp$fontface %||% gr$gp$font %||% integer(0)),
      lineheight = as.double(gr$gp$lineheight %||% double(0))
    )
    if (length(result) > 0) {
      rows <- result
    }
  }
  rows
}
