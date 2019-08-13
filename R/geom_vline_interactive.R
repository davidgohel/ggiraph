#' @title Vertical interactive reference line
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_vline}}.
#' See the documentation for those functions for more details.
#'
#' @seealso \code{\link{girafe}}
#' @inheritParams geom_point_interactive
#' @param xintercept controls the position of the line
#' @examples
#' # add interactive reference lines to a ggplot -------
#' @example examples/geom_vline_interactive.R
#' @export
geom_vline_interactive <- function(mapping = NULL, data = NULL,
                                   ...,
                                   xintercept,
                                   na.rm = FALSE,
                                   show.legend = NA) {

  # Act like an annotation
  if (!missing(xintercept)) {
    data <- data.frame(xintercept = xintercept)
    mapping <- aes(xintercept = xintercept)
    show.legend <- FALSE
  }

  layer(
    data = data,
    mapping = mapping,
    stat = StatIdentity,
    geom = GeomInteractiveVline,
    position = PositionIdentity,
    show.legend = show.legend,
    inherit.aes = FALSE,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}


#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveVline <- ggproto("GeomVline", Geom,
                                draw_panel = function(data, panel_scales, coord) {
                                  ranges <- coord$range(panel_scales)

                                  data$x    <- data$xintercept
                                  data$xend <- data$xintercept
                                  data$y    <- ranges$y[1]
                                  data$yend <- ranges$y[2]

                                  GeomInteractiveSegment$draw_panel(unique(data), panel_scales, coord)
                                },

                                default_aes = aes(colour = "black", size = 0.5, linetype = 1, alpha = NA, tooltip = NULL, onclick = NULL, data_id = NULL),
                                required_aes = "xintercept",

                                draw_key = draw_key_vline
)
