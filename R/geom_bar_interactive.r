#' @title add bars with tooltips or click actions
#'
#' @description
#' tooltips can be displayed when mouse is over bars, on click actions
#' can be set with javascript instructions.
#'
#' @seealso \code{\link{ggiraph}}
#' @inheritParams geom_point_interactive
#' @param width Bar width.
#' @examples
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

GeomInteractiveBar <- ggproto("GeomInteractiveBar", GeomRect,
  required_aes = "x",

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
