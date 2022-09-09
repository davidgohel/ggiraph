#' @title Create interactive line segments and curves
#'
#' @description
#' The geometries are based on [geom_segment()] and [geom_curve()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive segments and curves to a ggplot -------
#' @example examples/geom_segment_interactive.R
#' @seealso [girafe()]
#' @export
geom_segment_interactive <- function(...)
  layer_interactive(geom_segment, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveSegment <- ggproto(
  "GeomInteractiveSegment",
  GeomSegment,
  default_aes = add_default_interactive_aes(GeomSegment),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(data,
                        panel_params,
                        coord,
                        arrow = NULL,
                        arrow.fill = NULL,
                        lineend = "butt",
                        linejoin = "round",
                        na.rm = FALSE, 
                        .ipar = IPAR_NAMES) {
    data <- remove_missing(
      data,
      na.rm = na.rm,
      c(
        "x",
        "y",
        "xend",
        "yend",
        "linetype",
        "size",
        "shape",
        "tooltip",
        "onclick",
        "data_id"
      ),
      name = "geom_segment"
    )
    if (empty(data))
      return(zeroGrob())

    if (coord$is_linear()) {
      coord <- coord$transform(data, panel_params)
      arrow.fill <- arrow.fill %||% coord$colour

      gr <- segmentsGrob(
        coord$x,
        coord$y,
        coord$xend,
        coord$yend,
        default.units = "native",
        gp = gpar(
          col = alpha(coord$colour, coord$alpha),
          fill = alpha(arrow.fill, coord$alpha),
          lwd = coord$size * .pt,
          lty = coord$linetype,
          lineend = lineend,
          linejoin = linejoin
        ),
        arrow = arrow
      )
      gr <- add_interactive_attrs(gr, coord, ipar = .ipar)
      return(gr)
    }

    data$group <- 1:nrow(data)
    starts <- subset(data, select = c(-xend, -yend))
    ends <-
      rename(subset(data, select = c(-x, -y)), c("xend" = "x", "yend" = "y"))

    pieces <- rbind(starts, ends)
    pieces <- pieces[order(pieces$group),]

    GeomInteractivePath$draw_panel(pieces,
                                   panel_params,
                                   coord,
                                   arrow = arrow,
                                   lineend = lineend, 
                                   .ipar = .ipar)
  }
)
