#' @title Horizontal interactive reference line
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_hline}}.
#' See the documentation for those functions for more details.
#'
#' @seealso \code{\link{ggiraph}}
#' @inheritParams geom_point_interactive
#' @param yintercept controls the position of the line
#' @examples
#' # add interactive reference lines to a ggplot -------
#' @example examples/geom_hline_interactive.R
#' @export
geom_hline_interactive <- function(mapping = NULL, data = NULL,
                                   ...,
                                   yintercept,
                                   na.rm = FALSE,
                                   show.legend = NA) {

  # Act like an annotation
  if (!missing(yintercept)) {
    data <- data.frame(yintercept = yintercept)
    mapping <- aes(yintercept = yintercept)
    show.legend <- FALSE
  }

  layer(
    data = data,
    mapping = mapping,
    stat = StatIdentity,
    geom = GeomInteractiveHline,
    position = PositionIdentity,
    show.legend = show.legend,
    inherit.aes = FALSE,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}


GeomInteractiveHline <- ggproto("GeomHline", Geom,
                                draw_panel = function(data, panel_scales, coord) {
                                  ranges <- coord$range(panel_scales)

                                  data$x    <- ranges$x[1]
                                  data$xend <- ranges$x[2]
                                  data$y    <- data$yintercept
                                  data$yend <- data$yintercept

                                  GeomInteractiveSegment$draw_panel(unique(data), panel_scales, coord)
                                },

                                default_aes = aes(colour = "black", size = 0.5, linetype = 1, alpha = NA, tooltip = NULL, onclick = NULL, data_id = NULL),
                                required_aes = "yintercept",

                                draw_key = draw_key_path
)
