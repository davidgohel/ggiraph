#' Create interactive vertical intervals: lines, crossbars & errorbars
#'
#' @description
#' These geometries are based on [geom_crossbar()], [geom_errorbar()],
#' [geom_linerange()] and [geom_pointrange()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive intervals -------
#' @example examples/geom_crossbar_interactive.R
#' @seealso [girafe()]
#' @export
geom_crossbar_interactive <- function(...)
  layer_interactive(geom_crossbar, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveCrossbar <- ggproto(
  "GeomInteractiveCrossbar",
  GeomCrossbar,
  default_aes = add_default_interactive_aes(GeomCrossbar),
  draw_key = function(data, params, size) {
    gr <- GeomCrossbar$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data,
                        panel_params,
                        coord,
                        fatten = 2.5,
                        width = NULL,
                        flipped_aes = FALSE) {
    data <- flip_data(data, flipped_aes)

    middle <-
      transform(
        data,
        x = xmin,
        xend = xmax,
        yend = y,
        size = size * fatten,
        alpha = NA
      )

    has_notch <-
      !is.null(data$ynotchlower) && !is.null(data$ynotchupper) &&
      !is.na(data$ynotchlower) && !is.na(data$ynotchupper)
    if (has_notch) {
      if (data$ynotchlower < data$ymin  ||  data$ynotchupper > data$ymax)
        message("notch went outside hinges. Try setting notch=FALSE.")

      notchindent <-
        (1 - data$notchwidth) * (data$xmax - data$xmin) / 2

      middle$x <- middle$x + notchindent
      middle$xend <- middle$xend - notchindent

      box <- new_data_frame(
        list(
          x = c(
            data$xmin,
            data$xmin,
            data$xmin + notchindent,
            data$xmin,
            data$xmin,
            data$xmax,
            data$xmax,
            data$xmax - notchindent,
            data$xmax,
            data$xmax,
            data$xmin
          ),
          y = c(
            data$ymax,
            data$ynotchupper,
            data$y,
            data$ynotchlower,
            data$ymin,
            data$ymin,
            data$ynotchlower,
            data$y,
            data$ynotchupper,
            data$ymax,
            data$ymax
          ),
          alpha = rep(data$alpha, 11),
          colour = rep(data$colour, 11),
          size = rep(data$size, 11),
          linetype = rep(data$linetype, 11),
          fill = rep(data$fill, 11),
          group = rep(seq_len(nrow(data)), 11)
        )
      )
      box <- copy_interactive_attrs(data, box, 11)

    } else {
      # No notch
      box <- new_data_frame(
        list(
          x = c(data$xmin, data$xmin, data$xmax, data$xmax, data$xmin),
          y = c(data$ymax, data$ymin, data$ymin, data$ymax, data$ymax),
          alpha = rep(data$alpha, 5),
          colour = rep(data$colour, 5),
          size = rep(data$size, 5),
          linetype = rep(data$linetype, 5),
          fill = rep(data$fill, 5),
          group = rep(seq_len(nrow(data)), 5) # each bar forms it's own group
        )
      )
      box <- copy_interactive_attrs(data, box, 5)
    }
    box <- flip_data(box, flipped_aes)
    middle <- flip_data(middle, flipped_aes)

    ggname("geom_interactive_crossbar", gTree(
      children = gList(
        GeomInteractivePolygon$draw_panel(box, panel_params, coord),
        GeomInteractiveSegment$draw_panel(middle, panel_params, coord)
      )
    ))
  }
)
