#' @title Create interactive line segments
#'
#' @description
#' The geometry is based on [geom_segment()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive segments to a ggplot -------
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
  draw_key = function(data, params, size) {
    gr <- GeomSegment$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data,
                        panel_params,
                        coord,
                        arrow = NULL,
                        arrow.fill = NULL,
                        lineend = "butt",
                        linejoin = "round",
                        na.rm = FALSE) {
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

      coord <- force_interactive_aes_to_char(coord)

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
      gr <- add_interactive_attrs(gr, coord)
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
                                   lineend = lineend)
  }
)
