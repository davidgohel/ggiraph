#' @title Draw point-like short line segments
#' @description
#' This function is a copy of `geom_hpline()` of package 'ungeviz' authored
#' by Claus O. Wilke.
#'
#' The geom `geom_hpline()` can be used as a drop-in
#' replacement for [`geom_point()`] but draw horizontal lines
#' (point-lines, or plines) instead of points. These lines can often be useful to
#' indicate specific parameter estimates in a plot. The geom takes position
#' aesthetics as `x` and `y` like [`geom_point()`], and it uses `width`
#' to set the length of the line segment. All other aesthetics (`colour`, `size`,
#' `linetype`, etc.) are inherited from [`geom_segment()`].
#' @inheritParams ggplot2::geom_point
#' @examples
#' library(ggplot2)
#' library(ggiraph)
#' ggplot(iris, aes(Species, Sepal.Length)) +
#'   geom_hpline(stat = "summary")
#'
#' zz <- ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
#'   geom_point(color = "grey50", alpha = 0.3, size = 2) +
#'   geom_hpline_interactive(data = iris[1:5,], mapping = aes(tooltip = Species)) +
#'   theme_bw()
#' girafe(ggobj = zz)
#' @export
geom_hpline <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  ...,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE
) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomHpline,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}

#' @rdname geom_hpline
#' @format NULL
#' @usage NULL
#' @export
GeomHpline <- ggproto(
  "GeomHpline",
  GeomSegment,
  required_aes = c("x", "y"),
  non_missing_aes = c("linewidth", "colour", "linetype", "width"),
  default_aes = aes(
    width = 0.5,
    colour = "black",
    linewidth = 2,
    linetype = 1,
    alpha = NA
  ),

  draw_panel = function(
    self,
    data,
    panel_params,
    coord,
    arrow = NULL,
    arrow.fill = NULL,
    lineend = "butt",
    linejoin = "round",
    na.rm = FALSE
  ) {
    data <- transform(data, x = x - width / 2, xend = x + width / 2, yend = y)
    ggproto_parent(GeomSegment, self)$draw_panel(
      data,
      panel_params,
      coord,
      arrow = arrow,
      arrow.fill = arrow.fill,
      lineend = lineend,
      linejoin = linejoin,
      na.rm = na.rm
    )
  }
)

# geom_uppererrorbar_interactive -----
#' @export
#' @rdname geom_segment_interactive
geom_hpline_interactive <- function(...) {
  layer_interactive(geom_hpline, ...)
}

#' @export
#' @rdname geom_hpline
GeomInteractiveHpline <- ggproto(
  "GeomInteractiveHpline",
  GeomHpline,
  default_aes = add_default_interactive_aes(GeomHpline),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data, panel_params, coord, ..., .ipar = IPAR_NAMES) {
    zz <- GeomHpline$draw_panel(data, panel_params, coord, ...)
    coords <- coord$transform(data, panel_params)
    add_interactive_attrs(zz, coords, ipar = .ipar)
  }
)
