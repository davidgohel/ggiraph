#' @title Create interactive observations connections
#'
#' @description
#' These geometries are based on [ggplot2::geom_path()],
#' [ggplot2::geom_line()] and [ggplot2::geom_step()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive paths to a ggplot -------
#' @example examples/geom_path_interactive.R
#' @seealso [girafe()]
#' @export
geom_path_interactive <- function(...) {
  layer_interactive(geom_path, ...)
}

#' @importFrom stats complete.cases
#' @importFrom stats ave
#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractivePath <- ggproto(
  "GeomInteractivePath",
  GeomPath,
  default_aes = add_default_interactive_aes(GeomPath),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(self, data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    gr <- GeomPath$draw_panel(data, panel_params, coord, ...)
    if (is_zero(gr)) {
      return(gr)
    }
    if (inherits(gr, "segments")) {
      # aesthetics varying along the lines: one segment between two points
      data <- path_segment_data(data, coord, panel_params)
    } else {
      # one line per group, cut at its missing points
      data <- path_group_data(data)
    }
    add_interactive_attrs(gr, data, ipar = .ipar, by_shape = TRUE)
  }
)


#' @export
#' @rdname geom_path_interactive
geom_line_interactive <- function(...) {
  layer_interactive(geom_line, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveLine <- ggproto(
  "GeomInteractiveLine",
  GeomLine,
  default_aes = add_default_interactive_aes(GeomLine),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    GeomInteractivePath$draw_panel(
      data,
      panel_params,
      coord,
      ...,
      .ipar = .ipar
    )
  }
)

#' @export
#' @rdname geom_path_interactive
geom_step_interactive <- function(...) {
  layer_interactive(geom_step, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveStep <-
  ggproto(
    "GeomInteractiveStep",
    GeomStep,
    default_aes = add_default_interactive_aes(GeomStep),
    parameters = interactive_geom_parameters,
    draw_key = interactive_geom_draw_key,
    draw_panel = function(
      data,
      panel_params,
      coord,
      ...,
      direction = "hv",
      flipped_aes = FALSE,
      .ipar = IPAR_NAMES
    ) {
      gr <- GeomStep$draw_panel(
        data,
        panel_params,
        coord,
        ...,
        direction = direction,
        flipped_aes = flipped_aes
      )
      if (is_zero(gr)) {
        return(gr)
      }
      # the steps drawn by 'ggplot2', then the rules of paths
      data <- step_data(data, direction = direction, flipped_aes = flipped_aes)
      if (inherits(gr, "segments")) {
        data <- path_segment_data(data, coord, panel_params)
      } else {
        data <- path_group_data(data)
      }
      add_interactive_attrs(gr, data, ipar = .ipar, by_shape = TRUE)
    }
  )

#' Data of the steps drawn by `GeomStep$draw_panel()`
#' @details
#' As 'ggplot2' does: the stairsteps of each group, computed on the flipped
#' data for a horizontal orientation.
#' @noRd
step_data <- function(data, direction = "hv", flipped_aes = FALSE) {
  data <- flip_data(data, flipped_aes)
  if (isTRUE(flipped_aes)) {
    direction <- switch(direction, hv = "vh", vh = "hv", direction)
  }
  data <- dapply(data, "group", stairstep, direction = direction)
  flip_data(data, flipped_aes)
}

# Calculate stairsteps, copy of the internal function of 'ggplot2'
stairstep <- function(data, direction = "hv") {
  direction <- match.arg(direction, c("hv", "vh", "mid"))
  data <- as.data.frame(data)[order(data$x), ]
  n <- nrow(data)

  if (n <= 1) {
    # Need at least one observation
    return(data[0, , drop = FALSE])
  }

  if (direction == "vh") {
    xs <- rep(1:n, each = 2)[-2 * n]
    ys <- c(1, rep(2:n, each = 2))
  } else if (direction == "hv") {
    ys <- rep(1:n, each = 2)[-2 * n]
    xs <- c(1, rep(2:n, each = 2))
  } else {
    xs <- rep(1:(n - 1), each = 2)
    ys <- rep(1:n, each = 2)
  }

  if (direction == "mid") {
    gaps <- data$x[-1] - data$x[-n]
    mid_x <- data$x[-n] + gaps / 2 # map the mid-point between adjacent x-values
    x <- c(data$x[1], mid_x[xs], data$x[n])
    y <- c(data$y[ys])
    data_attr <- data[c(1, xs, n), setdiff(names(data), c("x", "y"))]
  } else {
    x <- data$x[xs]
    y <- data$y[ys]
    data_attr <- data[xs, setdiff(names(data), c("x", "y"))]
  }

  data_frame0(x = x, y = y, data_attr)
}

#' One data row per line drawn by `GeomPath$draw_panel()`
#' @details
#' 'ggplot2' draws a polyline with one line per group of at least 2 points,
#' sorted by group; a line takes the interactive parameters of the first
#' row of its group. The pieces and arrow heads of a line cut by missing
#' points take the value of their line (see `polyline_element_counts()`).
#' @noRd
path_group_data <- function(data) {
  data <- data[order(data$group), , drop = FALSE]
  n <- tabulate(match(data$group, unique0(data$group)))
  first <- !duplicated(data$group)
  data[first, , drop = FALSE][n >= 2, , drop = FALSE]
}

#' One data row per segment drawn by `GeomPath$draw_panel()`
#' @details
#' When the aesthetics vary along the lines, 'ggplot2' draws a segment
#' between two consecutive points of a line (after munching), with the
#' parameters of its first point. 'grid' draws only the segments whose ends
#' are finite.
#' @noRd
path_segment_data <- function(data, coord, panel_params) {
  data <- data[order(data$group), , drop = FALSE]
  munched <- coord_munch(coord, data, panel_params)
  rows <- stats::ave(seq_len(nrow(munched)), munched$group, FUN = length)
  munched <- munched[rows >= 2, , drop = FALSE]
  n <- nrow(munched)
  if (n < 2) {
    return(munched[0, , drop = FALSE])
  }
  end <- c(munched$group[-1] != munched$group[-n], TRUE)
  start <- munched[!end, , drop = FALSE]
  stop <- munched[c(FALSE, !end[-n]), , drop = FALSE]
  drawn <- is.finite(start$x) & is.finite(start$y) &
    is.finite(stop$x) & is.finite(stop$y)
  start[drawn, , drop = FALSE]
}
