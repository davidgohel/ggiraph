#' @title Create interactive polyline grob
#'
#' @description
#' These grobs are based on [polylineGrob()] and [linesGrob()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_polyline_grob <- function(...) {
  grob_interactive(grid::polylineGrob, ...)
}

#' @export
drawDetails.interactive_polyline_grob <- function(x, recording) {
  dsvg_tracer_on()
  NextMethod()
  ids <- dsvg_tracer_off()
  if (length(ids) > 0) {
    id <- polyline_id(x)
    # the values are those of the first point of each line
    rows <- which(c(TRUE, id[-1] != id[-length(id)]))
    # a line can give several elements (cut by NA, arrow heads) or none
    # (blank linetype): repeat each value for the elements of its line.
    # The counts can differ even when their sum is the number of lines.
    if (!is.unsorted(id)) {
      counts <- polyline_element_counts(x, id)
      if (sum(counts) == length(ids)) {
        rows <- rep(rows, counts)
      }
    }
    interactive_attr_toxml(x = x, ids = ids, rows = rows)
  }
  invisible()
}

#' Line of each point of a polyline grob
#' @noRd
polyline_id <- function(x) {
  n <- length(x$x)
  if (!is.null(x$id)) {
    rep_len(x$id, n)
  } else if (!is.null(x$id.lengths)) {
    rep(seq_along(x$id.lengths), x$id.lengths)
  } else {
    rep(1L, n)
  }
}

#' Number of elements drawn for each line of a polyline grob
#' @details
#' Follows the rules of 'grid' (`gridLines()` in grid.c) and of the graphics
#' engine (`GEPolyline()` in engine.c):
#' - a line is cut at its missing or infinite points, and only the pieces of
#'   at least 2 points are drawn;
#' - an arrow head is drawn at the start of a line when its first piece
#'   starts at the first point, at the end when its last piece ends at the
#'   last point;
#' - nothing is drawn with a blank linetype or a missing line width.
#'
#' The device clips itself (`deviceClip`), so lines are not cut at the
#' device extent. Only missing and infinite values matter: the units are not
#' converted when they are all of the same type.
#' @param x a polyline grob
#' @param id the line of each point, sorted
#' @return the number of elements of each line, in the order of the lines
#' @noRd
polyline_element_counts <- function(x, id) {
  n <- length(id)
  line <- match(id, unique(id))
  n_lines <- max(line)
  as_values <- function(u, convert) {
    types <- grid::unitType(u)
    if (all(types == types[1]) && types[1] != "sum") {
      as.numeric(u)
    } else {
      convert(u, "inches", valueOnly = TRUE)
    }
  }
  x_values <- rep_len(as_values(x$x, grid::convertX), n)
  y_values <- rep_len(as_values(x$y, grid::convertY), n)
  ok <- is.finite(x_values) & is.finite(y_values)
  lty <- rep_len(x$gp$lty %||% "solid", n_lines)
  lwd <- rep_len(x$gp$lwd %||% 1, n_lines)
  not_drawn <- is.na(lty) | lty %in% c("blank", "0") | is.na(lwd)

  # usual case: one element per line
  if (all(ok) && is.null(x$arrow) && !any(not_drawn)) {
    return(rep(1L, n_lines))
  }

  # pieces of finite points within a line
  same_line <- c(FALSE, line[-1] == line[-n])
  piece_start <- ok & !(c(FALSE, ok[-n]) & same_line)
  piece <- cumsum(piece_start)
  piece_length <- tabulate(piece[ok], nbins = max(piece, 0L))
  drawn <- piece_length > 1
  counts <- tabulate(line[piece_start][drawn], nbins = n_lines)

  if (!is.null(x$arrow)) {
    ends <- rep_len(x$arrow$ends, n_lines)
    in_drawn_piece <- function(k) {
      ok[k] & piece_length[pmax(piece[k], 1L)] > 1
    }
    first_point <- match(seq_len(n_lines), line)
    last_point <- n + 1L - match(seq_len(n_lines), rev(line))
    counts <- counts +
      (ends %in% c(1, 3)) * in_drawn_piece(first_point) +
      (ends %in% c(2, 3)) * in_drawn_piece(last_point)
  }

  counts[not_drawn] <- 0L
  as.integer(counts)
}

#' @rdname interactive_polyline_grob
#' @export
interactive_lines_grob <- function(...) {
  grob_interactive(grid::linesGrob, ...)
}

#' @export
drawDetails.interactive_lines_grob <- function(x, recording) {
  dsvg_tracer_on()
  NextMethod()
  ids <- dsvg_tracer_off()
  if (length(ids) > 0) {
    if (is.null(x$id) && is.null(x$id.lengths)) {
      x$id <- rep(1, length(x$x))
    }
    .w = c(TRUE, x$id[-1] != x$id[-length(x$id)])
    interactive_attr_toxml(x = x, ids = ids, rows = .w)
  }
  invisible()
}
