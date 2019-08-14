#' @title interactive polygons
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_polygon}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add interactive polygons to a ggplot -------
#' @example examples/geom_polygon_interactive.R
#' @seealso \code{\link{girafe}}
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
  draw_panel = function(data, panel_params, coord, rule = "evenodd") {
    n <- nrow(data)
    if (n == 1)
      return(zeroGrob())

    munched <- coord_munch(coord, data, panel_params)

    if (is.null(munched$subgroup)) {
      # Sort by group to make sure that colors, fill, etc. come in same order
      munched <- munched[order(munched$group),]

      # For gpar(), there is one entry per polygon (not one entry per point).
      # We'll pull the first value from each group, and assume all these values
      # are the same within each group.
      first_idx <- !duplicated(munched$group)
      first_rows <- munched[first_idx,]

      munched <- force_interactive_aes_to_char(munched)

      ggname(
        "geom_polygon_interactive",
        interactive_polygon_grob(
          munched$x,
          munched$y,
          default.units = "native",
          id = munched$group,
          tooltip = munched$tooltip,
          onclick = munched$onclick,
          data_id = munched$data_id,
          gp = gpar(
            col = first_rows$colour,
            fill = alpha(first_rows$fill, first_rows$alpha),
            lwd = first_rows$size * .pt,
            lty = first_rows$linetype
          )
        )
      )
    } else {
      if (utils::packageVersion('grid') < "3.6") {
        stop("Polygons with holes requires R 3.6 or above", call. = FALSE)
      }
      # Sort by group to make sure that colors, fill, etc. come in same order
      munched <- munched[order(munched$group, munched$subgroup),]
      id <- match(munched$subgroup, unique(munched$subgroup))

      # For gpar(), there is one entry per polygon (not one entry per point).
      # We'll pull the first value from each group, and assume all these values
      # are the same within each group.
      first_idx <- !duplicated(munched$group)
      first_rows <- munched[first_idx,]

      munched <- force_interactive_aes_to_char(munched)

      ggname(
        "geom_path_interactive",
        interactive_path_grob(
          munched$x,
          munched$y,
          default.units = "native",
          id = id,
          pathId = munched$group,
          rule = rule,
          tooltip = munched$tooltip,
          onclick = munched$onclick,
          data_id = munched$data_id,
          gp = gpar(
            col = first_rows$colour,
            fill = alpha(first_rows$fill, first_rows$alpha),
            lwd = first_rows$size * .pt,
            lty = first_rows$linetype
          )
        )
      )
    }
  }
)
