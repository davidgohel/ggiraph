#' @title Create interactive segments grob
#'
#' @description
#' The grob is based on [segmentsGrob][grid::grid.segments].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @return An interactive grob object.
#' @inheritSection interactive_parameters Details for interactive_*_grob functions
#' @seealso [girafe()]
#' @export
interactive_segments_grob <- function(...) {
  grob_interactive(grid::segmentsGrob, ...)
}

#' @export
drawDetails.interactive_segments_grob <- function(x, recording) {
  dsvg_tracer_on()
  NextMethod()
  ids <- dsvg_tracer_off()
  rows <- NULL
  counts <- segments_element_counts(x)
  if (sum(counts) == length(ids)) {
    rows <- rep(seq_along(counts), counts)
  }
  interactive_attr_toxml(x = x, ids = ids, rows = rows)
  invisible()
}

#' Number of elements drawn for each segment of a segments grob
#' @details
#' A segment with a missing or infinite coordinate, a blank linetype or a
#' missing line width is not drawn, nor its arrow heads. Otherwise it is a
#' line, plus a head at each end with an arrow (`ends` 1 or 2: one head,
#' 3: two heads), even of zero length: 'ggplot2' gives zero length heads
#' at both ends of the inner segments of a path with an arrow at both ends.
#' Only missing and infinite values matter: the units are not converted
#' when they are all of the same type.
#' @param x a segments grob
#' @return the number of elements of each segment
#' @noRd
segments_element_counts <- function(x) {
  as_values <- function(u, convert) {
    types <- grid::unitType(u)
    if (all(types == types[1]) && types[1] != "sum") {
      as.numeric(u)
    } else {
      convert(u, "inches", valueOnly = TRUE)
    }
  }
  values <- list(
    as_values(x$x0, grid::convertX),
    as_values(x$y0, grid::convertY),
    as_values(x$x1, grid::convertX),
    as_values(x$y1, grid::convertY)
  )
  n <- max(lengths(values))
  ok <- Reduce(`&`, lapply(values, function(v) is.finite(rep_len(v, n))))
  lty <- rep_len(x$gp$lty %||% "solid", n)
  lwd <- rep_len(x$gp$lwd %||% 1, n)
  drawn <- ok & !(is.na(lty) | lty %in% c("blank", "0") | is.na(lwd))
  heads <- 0L
  if (!is.null(x$arrow)) {
    ends <- rep_len(x$arrow$ends, n)
    heads <- (ends %in% c(1, 2)) + 2L * (ends == 3)
  }
  as.integer(drawn * (1L + heads))
}
