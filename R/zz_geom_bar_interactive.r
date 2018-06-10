#' @title interactive bars
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_bar}}.
#' See the documentation for those functions for more details.
#'
#' @seealso \code{\link{ggiraph}}
#' @inheritParams geom_point_interactive
#' @param width Bar width.
#' @examples
#' library(ggplot2)
#' g <- ggplot(mpg, aes( x = class, tooltip = class,
#'         data_id = class ) ) +
#'   geom_bar_interactive()
#' ggiraph(code = print(g))
#'
#' dat <- data.frame( name = c( "David", "Constance", "Leonie" ),
#'     gender = c( "Male", "Female", "Female" ),
#'     height = c(172, 159, 71 ) )
#' g <- ggplot(dat, aes( x = name, y = height, tooltip = gender,
#'         data_id = name ) ) +
#'   geom_bar_interactive(stat = "identity")
#' ggiraph(code = print(g))
#' @export
geom_bar_interactive <- function(mapping = NULL, data = NULL,
                     stat = "count", position = "stack",
                     ...,
                     width = NULL,
                     na.rm = FALSE,
                     show.legend = NA,
                     inherit.aes = TRUE) {

  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomInteractiveBar,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      width = width,
      na.rm = na.rm,
      ...
    )
  )
}

"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveBar <- ggproto("GeomInteractiveBar", GeomInteractiveRect,
          required_aes = c("x", "y"),

  setup_data = function(data, params) {
    data$width <- data$width %||%
      params$width %||% (resolution(data$x, FALSE) * 0.9)
    transform(data,
      ymin = pmin(y, 0), ymax = pmax(y, 0),
      xmin = x - width / 2, xmax = x + width / 2, width = NULL
    )
  },

  draw_panel = function(self, data, panel_scales, coord, width = NULL) {
    ggproto_parent(GeomInteractiveRect, self)$draw_panel(data, panel_scales, coord)
  }
)
