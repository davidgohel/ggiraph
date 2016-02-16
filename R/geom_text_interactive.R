#' @importFrom ggplot2 position_nudge
#' @title add text with tooltips or click actions or double click actions
#'
#' @description
#' tooltips can be displayed when mouse is over polygons, on click actions and
#' double click actions can be set with javascript instructions.
#'
#' @seealso \code{\link{ggiraph}}
#' @inheritParams geom_point_interactive
#' @param parse See \code{\link[ggplot2]{geom_point}}.
#' @param nudge_x,nudge_y See \code{\link[ggplot2]{geom_point}}.
#' @param check_overlap See \code{\link[ggplot2]{geom_point}}.
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_text_interactive.R
#' @export
geom_text_interactive <- function(mapping = NULL, data = NULL, stat = "identity",
                                  position = "identity", parse = FALSE, ...,
                                  nudge_x = 0, nudge_y = 0, check_overlap = FALSE,
                                  na.rm = FALSE, show.legend = NA, inherit.aes = TRUE)
{
  if (!missing(nudge_x) || !missing(nudge_y)) {
    if (!missing(position)) {
      stop("Specify either `position` or `nudge_x`/`nudge_y`", call. = FALSE)
    }

    position <- position_nudge(nudge_x, nudge_y)
  }

  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomInteractiveText,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      parse = parse,
      check_overlap = check_overlap,
      na.rm = na.rm,
      ...
    )
  )
}


GeomInteractiveText <- ggproto(
  "GeomInteractiveText",
  Geom,
  required_aes = c("x", "y", "label"),

  default_aes = aes(
    colour = "black",
    size = 3.88,
    angle = 0,
    hjust = 0.5,
    vjust = 0.5,
    alpha = NA,
    family = "",
    fontface = 1,
    lineheight = 1.2
  ),

  draw_panel = function(data,
                        panel_scales,
                        coord,
                        parse = FALSE,
                        na.rm = FALSE,
                        check_overlap = FALSE) {
    lab <- data$label
    if (parse) {
      lab <- parse(text = as.character(lab))
    }

    data <- coord$transform(data, panel_scales)
    if (is.character(data$vjust)) {
      data$vjust <- compute_just(data$vjust, data$y)
    }
    if (is.character(data$hjust)) {
      data$hjust <- compute_just(data$hjust, data$x)
    }

    if( !is.null(data$tooltip) && !is.character(data$tooltip) )
      data$tooltip <- as.character(data$tooltip)
    if( !is.null(data$onclick) && !is.character(data$onclick) )
      data$onclick <- as.character(data$onclick)
    if( !is.null(data$data_id) && !is.character(data$data_id) )
      data$data_id <- as.character(data$data_id)

    interactive_text_grob(
      lab,
      data$x,
      data$y,
      tooltip = data$tooltip,
      onclick = data$onclick,
      data_id = data$data_id,
      default.units = "native",
      hjust = data$hjust,
      vjust = data$vjust,
      rot = data$angle,
      gp = gpar(
        col = alpha(data$colour, data$alpha),
        fontsize = data$size * .pt,
        fontfamily = data$family,
        fontface = data$fontface,
        lineheight = data$lineheight
      ),
      check.overlap = check_overlap
    )
  },

  draw_key = draw_key_text
)


compute_just <- function(just, x) {
  inward <- just == "inward"
  just[inward] <- c("left", "middle", "right")[just_dir(x[inward])]
  outward <- just == "outward"
  just[outward] <- c("right", "middle", "left")[just_dir(x[outward])]

  unname(c(left = 0, center = 0.5, right = 1,
           bottom = 0, middle = 0.5, top = 1)[just])
}

just_dir <- function(x, tol = 0.001) {
  out <- rep(2L, length(x))
  out[x < 0.5 - tol] <- 1L
  out[x > 0.5 + tol] <- 3L
  out
}

