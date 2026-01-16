#' @title Create interactive ribbons and area plots
#'
#' @description
#' The geometries are based on [ggplot2::geom_ribbon()] and [ggplot2::geom_area()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive bar -------
#' @example examples/geom_ribbon_interactive.R
#' @seealso [girafe()]
#' @export
geom_ribbon_interactive <- function(...) {
  layer_interactive(geom_ribbon, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveRibbon <- ggproto(
  "GeomInteractiveRibbon",
  GeomRibbon,
  default_aes = add_default_interactive_aes(GeomRibbon),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(
    data,
    ...,
    .ipar = IPAR_NAMES
  ) {
    ia <- get_interactive_attr_names(data, ipar = .ipar)
    aes <- lapply(
      data[names(data) %in% ia],
      unique0
    )

    grtree <- GeomRibbon$draw_group(data, ...)

    polygon_child_index <- which(grepl("polygon", names(grtree$children)))[1]
    if (length(polygon_child_index) == 1L && is.finite(polygon_child_index)) {
      grtree$children[[polygon_child_index]] <-
        add_interactive_attrs(
          grtree$children[[polygon_child_index]],
          aes,
          ipar = .ipar
        )
    }

    polyline_child_index <- which(grepl("polyline", names(grtree$children)))[1]
    if (length(polyline_child_index) == 1L && is.finite(polyline_child_index)) {
      grtree$children[[polyline_child_index]] <-
        add_interactive_attrs(
          grtree$children[[polyline_child_index]],
          aes,
          ipar = .ipar
        )
      grtree$children[[polyline_child_index]]$.interactive_hooks <- c("fill_na")
    }

    grtree
  }
)

#' @rdname geom_ribbon_interactive
#' @export
geom_area_interactive <- function(...) {
  layer_interactive(geom_area, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveArea <- ggproto(
  "GeomInteractiveArea",
  GeomArea,
  default_aes = add_default_interactive_aes(GeomArea),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(..., .ipar = IPAR_NAMES) {
    GeomInteractiveRibbon$draw_group(..., .ipar = .ipar)
  }
)
