#' @title interactive observations connections
#'
#' @description
#' These geometries are based on \code{\link[ggplot2]{geom_path}} and
#' \code{\link[ggplot2]{geom_line}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add interactive paths to a ggplot -------
#' @example examples/geom_path_interactive.R
#' @seealso \code{\link{girafe}}
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
#' @include utils.R
GeomInteractivePath <- ggproto(
  "GeomInteractivePath",
  GeomPath,
  default_aes = add_default_interactive_aes(GeomPath),
  draw_key = function(data, params, size) {
    gr <- draw_key_path(data, params, size)
    add_interactive_attrs(gr, data, cl = NULL, data_attr = "key-id")
  },
  draw_panel = function(data,
                        panel_params,
                        coord,
                        arrow = NULL,
                        lineend = "butt",
                        linejoin = "round",
                        linemitre = 10,
                        na.rm = FALSE) {
    if (!anyDuplicated(data$group)) {
      message_wrap(
        "geom_path: Each group consists of only one observation. ",
        "Do you need to adjust the group aesthetic?"
      )
    }

    # must be sorted on group
    data <- data[order(data$group), , drop = FALSE]
    munched <- coord_munch(coord, data, panel_params)

    # Silently drop lines with less than two points, preserving order
    rows <-
      stats::ave(seq_len(nrow(munched)), munched$group, FUN = length)
    munched <- munched[rows >= 2, ]
    if (nrow(munched) < 2)
      return(zeroGrob())

    # Work out whether we should use lines or segments
    attr <- dapply(munched, "group", function(df) {
      linetype <- unique(df$linetype)
      new_data_frame(list(
        solid = identical(linetype, 1) || identical(linetype, "solid"),
        constant = nrow(unique(df[, c("alpha", "colour", "size", "linetype")])) == 1
      ),
      n = 1)
    })
    solid_lines <- all(attr$solid)
    constant <- all(attr$constant)
    if (!solid_lines && !constant) {
      stop(
        "geom_path_interactive: If you are using dotted or dashed lines",
        ", colour, size and linetype must be constant over the line",
        call. = FALSE
      )
    }

    # Work out grouping variables for grobs
    n <- nrow(munched)
    group_diff <- munched$group[-1] != munched$group[-n]
    start <- c(TRUE, group_diff)
    end <-   c(group_diff, TRUE)

    munched <- force_interactive_aes_to_char(munched)

    if (!constant) {
      interactive_segments_grob(
        munched$x[!end],
        munched$y[!end],
        munched$x[!start],
        munched$y[!start],
        tooltip = munched$tooltip[!end],
        onclick = munched$onclick[!end],
        data_id = munched$data_id[!end],
        default.units = "native",
        arrow = arrow,
        gp = gpar(
          col = alpha(munched$colour, munched$alpha)[!end],
          fill = alpha(munched$colour, munched$alpha)[!end],
          lwd = munched$size[!end] * .pt,
          lty = munched$linetype[!end],
          lineend = lineend,
          linejoin = linejoin,
          linemitre = linemitre
        )
      )
    } else {
      id <- match(munched$group, unique(munched$group))
      interactive_polyline_grob(
        munched$x,
        munched$y,
        id = id,
        tooltip = munched$tooltip,
        onclick = munched$onclick,
        data_id = munched$data_id,
        default.units = "native",
        arrow = arrow,
        gp = gpar(
          col = alpha(munched$colour, munched$alpha)[start],
          fill = alpha(munched$colour, munched$alpha)[start],
          lwd = munched$size[start] * .pt,
          lty = munched$linetype[start],
          lineend = lineend,
          linejoin = linejoin,
          linemitre = linemitre
        )
      )
    }
  }
)


#' @export
#' @rdname geom_path_interactive
#' @include utils.R
geom_line_interactive <- function(...) {
  layer_interactive(geom_line, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveLine <- ggproto(
  "GeomInteractiveLine",
  GeomInteractivePath,
  setup_data = function(data, params) {
    data[order(data$PANEL, data$group, data$x), ]
  }
)
