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
  # an expression (plotmath) gives a number of elements that depends on its
  # content: the expressions are drawn one at a time
  if (is.expression(x$label) && length(x$label) > 1) {
    draw_expressions_one_by_one(x)
    return(invisible())
  }
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

#' Draw the expressions of an interactive text grob one at a time
#' @details
#' 'plotmath' draws an expression with several elements (pieces of text,
#' lines), their number depends on the expression. Each expression is drawn
#' alone, as 'grid' would draw it (same position, justification, rotation
#' and graphical parameters), and its elements take its interactive
#' parameters. With `check.overlap`, only the expressions drawn by 'grid'
#' are drawn.
#' @noRd
draw_expressions_one_by_one <- function(x) {
  n <- max(length(x$x), length(x$y))
  rows <- seq_len(n)
  if (x$check.overlap && n > 1) {
    rows <- get_non_overlapping_rows(x) %||% rows
  }
  pick <- function(v, i) if (length(v) > 1) v[(i - 1L) %% length(v) + 1L] else v
  gp <- unclass(x$gp)
  ids <- list()
  for (i in rows) {
    gr <- grid::textGrob(
      label = x$label[(i - 1L) %% length(x$label) + 1L],
      x = x$x[(i - 1L) %% length(x$x) + 1L],
      y = x$y[(i - 1L) %% length(x$y) + 1L],
      hjust = pick(grid::resolveHJust(x$just, x$hjust), i),
      vjust = pick(grid::resolveVJust(x$just, x$vjust), i),
      rot = pick(x$rot, i),
      gp = do.call(grid::gpar, lapply(gp, pick, i = i))
    )
    dsvg_tracer_on()
    grid::grid.draw(gr)
    ids[[length(ids) + 1L]] <- dsvg_tracer_off()
  }
  interactive_attr_toxml(
    x = x,
    ids = unlist(ids),
    rows = rep(rows, lengths(ids))
  )
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
