#' @title Create interactive observations connections
#'
#' @description
#' These geometries are based on [geom_path()],
#' [geom_line()] and [geom_step()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive paths to a ggplot -------
#' @example examples/geom_path_interactive.R
#' @seealso [girafe()]
#' @export
geom_path_interactive <- function(...)
  layer_interactive(geom_path, ...)

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
  draw_key = function(data, params, size) {
    gr <- GeomPath$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
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
      abort(
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
      gr <- segmentsGrob(
        munched$x[!end],
        munched$y[!end],
        munched$x[!start],
        munched$y[!start],
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
      add_interactive_attrs(gr, munched, rows = !end)
    } else {
      id <- match(munched$group, unique(munched$group))
      gr <- polylineGrob(
        munched$x,
        munched$y,
        id = id,
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
      add_interactive_attrs(gr, munched)
    }
  }
)


#' @export
#' @rdname geom_path_interactive
geom_line_interactive <- function(...)
  layer_interactive(geom_line, ...)

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

#' @export
#' @rdname geom_path_interactive
geom_step_interactive <- function(...)
  layer_interactive(geom_step, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveStep <-
  ggproto(
    "GeomInteractiveStep",
    GeomInteractivePath,
    draw_panel = function(data, panel_params, coord, direction = "hv") {
      data <- dapply(data, "group", stairstep, direction = direction)
      GeomInteractivePath$draw_panel(data, panel_params, coord)
    }
  )

# Calculate stairsteps
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
  } else if (direction == "mid") {
    xs <- rep(1:(n-1), each = 2)
    ys <- rep(1:n, each = 2)
  } else {
    abort("Parameter `direction` is invalid.")
  }

  if (direction == "mid") {
    gaps <- data$x[-1] - data$x[-n]
    mid_x <- data$x[-n] + gaps/2 # map the mid-point between adjacent x-values
    x <- c(data$x[1], mid_x[xs], data$x[n])
    y <- c(data$y[ys])
    data_attr <- data[c(1,xs,n), setdiff(names(data), c("x", "y"))]
  } else {
    x <- data$x[xs]
    y <- data$y[ys]
    data_attr <- data[xs, setdiff(names(data), c("x", "y"))]
  }

  new_data_frame(c(list(x = x, y = y), data_attr))
}
