#' @title Create interactive polygons
#'
#' @description
#' The geometry is based on [ggplot2::geom_polygon()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_polygon_interactive.R
#' @seealso [girafe()]
#' @export
geom_polygon_interactive <- function(...) {
  layer_interactive(geom_polygon, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @include geom_path_interactive.R
GeomInteractivePolygon <- ggproto(
  "GeomInteractivePolygon",
  GeomPolygon,
  default_aes = add_default_interactive_aes(GeomPolygon),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(
    data,
    panel_params,
    coord,
    rule = "evenodd",
    lineend = "butt",
    linejoin = "round",
    linemitre = 10,
    .ipar = IPAR_NAMES
  ) {
    n <- nrow(data)
    if (n == 1) {
      return(zeroGrob())
    }

    munched <- coord_munch(coord, data, panel_params, is_closed = TRUE)

    if (is.null(munched$subgroup)) {
      # Sort by group to make sure that colors, fill, etc. come in same order
      munched <- munched[order(munched$group), ]

      # For gpar(), there is one entry per polygon (not one entry per point).
      # We'll pull the first value from each group, and assume all these values
      # are the same within each group.
      first_idx <- !duplicated(munched$group)
      first_rows <- munched[first_idx, ]

      gr <- ggname(
        "geom_polygon_interactive",
        polygonGrob(
          munched$x,
          munched$y,
          default.units = "native",
          id = munched$group,
          gp = gpar(
            col = first_rows$colour,
            fill = fill_alpha(first_rows$fill, first_rows$alpha),
            lwd = first_rows$linewidth * .pt,
            lty = first_rows$linetype,
            lineend = lineend,
            linejoin = linejoin,
            linemitre = linemitre
          )
        )
      )
      add_interactive_attrs(gr, munched, ipar = .ipar)
    } else {
      # Sort by group to make sure that colors, fill, etc. come in same order
      munched <- munched[order(munched$group, munched$subgroup), ]
      id <- match(munched$subgroup, unique(munched$subgroup))

      # For gpar(), there is one entry per polygon (not one entry per point).
      # We'll pull the first value from each group, and assume all these values
      # are the same within each group.
      first_idx <- !duplicated(munched$group)
      first_rows <- munched[first_idx, ]
      gr <- pathGrob(
        x = munched$x,
        y = munched$y,
        default.units = "native",
        id = id,
        pathId = munched$group,
        rule = rule,
        gp = gpar(
          col = first_rows$colour,
          fill = fill_alpha(first_rows$fill, first_rows$alpha),
          lwd = first_rows$linewidth * .pt,
          lty = first_rows$linetype,
          lineend = lineend,
          linejoin = linejoin,
          linemitre = linemitre
        )
      )
      add_interactive_attrs(gr, munched, ipar = .ipar)
    }
  }
)
