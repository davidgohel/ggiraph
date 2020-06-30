#' @title Create interactive boxplot
#'
#' @description
#' The geometry is based on [geom_boxplot()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive boxplot -------
#' @example examples/geom_boxplot_interactive.R
#' @seealso [girafe()]
#' @export
geom_boxplot_interactive  <- function(...)
  layer_interactive(geom_boxplot, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveBoxplot <- ggproto(
  "GeomInteractiveBoxplot",
  GeomBoxplot,
  default_aes = add_default_interactive_aes(GeomBoxplot),
  draw_key = function(data, params, size) {
    gr <- GeomBoxplot$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_group = function(data,
                        panel_params,
                        coord,
                        fatten = 2,
                        outlier.colour = NULL,
                        outlier.fill = NULL,
                        outlier.shape = 19,
                        outlier.size = 1.5,
                        outlier.stroke = 0.5,
                        outlier.alpha = NULL,
                        notch = FALSE,
                        notchwidth = 0.5,
                        varwidth = FALSE,
                        flipped_aes = FALSE) {
    data <- flip_data(data, flipped_aes)
    # this may occur when using geom_boxplot(stat = "identity")
    if (nrow(data) != 1) {
      abort("Can't draw more than one boxplot per group. Did you forget aes(group = ...)?")
    }

    common <- list(
      colour = data$colour,
      size = data$size,
      linetype = data$linetype,
      fill = alpha(data$fill, data$alpha),
      group = data$group
    )
    common <- copy_interactive_attrs(data, common)

    whiskers <- new_data_frame(c(list(
      x = c(data$x, data$x),
      xend = c(data$x, data$x),
      y = c(data$upper, data$lower),
      yend = c(data$ymax, data$ymin),
      alpha = c(NA_real_, NA_real_)
    ),
    common), n = 2)
    whiskers <- flip_data(whiskers, flipped_aes)

    box <- new_data_frame(c(
      list(
        xmin = data$xmin,
        xmax = data$xmax,
        ymin = data$lower,
        y = data$middle,
        ymax = data$upper,
        ynotchlower = ifelse(notch, data$notchlower, NA),
        ynotchupper = ifelse(notch, data$notchupper, NA),
        notchwidth = notchwidth,
        alpha = data$alpha
      ),
      common
    ))
    box <- flip_data(box, flipped_aes)

    if (!is.null(data$outliers) &&
        length(data$outliers[[1]] >= 1)) {
      outl <- list(
        y = data$outliers[[1]],
        x = data$x[1],
        tooltip = formatC(data$outliers[[1]]),
        colour = outlier.colour %||% data$colour[1],
        fill = outlier.fill %||% data$fill[1],
        shape = outlier.shape %||% data$shape[1],
        size = outlier.size %||% data$size[1],
        stroke = outlier.stroke %||% data$stroke[1],
        fill = NA,
        alpha = outlier.alpha %||% data$alpha[1]
      )
      if (!is.null(data$data_id[1])) {
        outl$data_id <- data$data_id[1]
      }
      outliers <- new_data_frame(
        outl,
        n = length(data$outliers[[1]])
      )
      outliers <- flip_data(outliers, flipped_aes)
      outliers_grob <-
        GeomInteractivePoint$draw_panel(outliers, panel_params, coord)
    } else {
      outliers_grob <- NULL
    }

    ggname(
      "geom_boxplot_interactive",
      grobTree(
        outliers_grob,
        GeomInteractiveSegment$draw_panel(whiskers, panel_params, coord),
        GeomInteractiveCrossbar$draw_panel(box, fatten = fatten, panel_params, coord, flipped_aes = flipped_aes)
      )
    )
  }
)
