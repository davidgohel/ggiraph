#' @title interactive boxplot
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_boxplot}}.
#' See the documentation for those functions for more details.
#'
#' @seealso \code{\link{ggiraph}}
#' @inheritParams geom_point_interactive
#' @param stat see \code{geom_boxplot}.
#' @param outlier.colour see \code{geom_boxplot}.
#' @param outlier.color see \code{geom_boxplot}.
#' @param outlier.shape see \code{geom_boxplot}.
#' @param outlier.size see \code{geom_boxplot}.
#' @param outlier.stroke see \code{geom_boxplot}.
#' @param notch see \code{geom_boxplot}.
#' @param notchwidth see \code{geom_boxplot}.
#' @param varwidth see \code{geom_boxplot}.
#' @examples
#' # add interactive boxplot -------
#' @example examples/geom_boxplot_interactive.R
#' @export
geom_boxplot_interactive <- function(
  mapping = NULL, data = NULL,
  stat = "boxplot", position = "dodge",
  ...,
  outlier.colour = NULL,
  outlier.color = NULL,
  outlier.shape = 19,
  outlier.size = 1.5,
  outlier.stroke = 0.5,
  notch = FALSE,
  notchwidth = 0.5,
  varwidth = FALSE,
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomInteractiveBoxplot,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      outlier.colour = outlier.color %||% outlier.colour,
      outlier.shape = outlier.shape,
      outlier.size = outlier.size,
      outlier.stroke = outlier.stroke,
      notch = notch,
      notchwidth = notchwidth,
      varwidth = varwidth,
      na.rm = na.rm,
      ...
    )
  )
}



#' @importFrom ggplot2 remove_missing
#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveBoxplot <- ggproto(
  "GeomInteractiveBoxplot", Geom,
  setup_data = function(data, params) {
    data$width <- data$width %||%
      params$width %||% (resolution(data$x, FALSE) * 0.9)

    if (!is.null(data$outliers)) {
      suppressWarnings({
        out_min <- vapply(data$outliers, min, numeric(1))
        out_max <- vapply(data$outliers, max, numeric(1))
      })

      data$ymin_final <- pmin(out_min, data$ymin)
      data$ymax_final <- pmax(out_max, data$ymax)
    }

    # if `varwidth` not requested or not available, don't use it
    if (is.null(params) || is.null(params$varwidth) || !params$varwidth || is.null(data$relvarwidth)) {
      data$xmin <- data$x - data$width / 2
      data$xmax <- data$x + data$width / 2
    } else {
      # make `relvarwidth` relative to the size of the largest group
      data$relvarwidth <- data$relvarwidth / max(data$relvarwidth)
      data$xmin <- data$x - data$relvarwidth * data$width / 2
      data$xmax <- data$x + data$relvarwidth * data$width / 2
    }
    data$width <- NULL
    if (!is.null(data$relvarwidth)) data$relvarwidth <- NULL

    data
  },

  draw_group = function(data, panel_scales, coord, fatten = 2,
                        outlier.colour = NULL, outlier.shape = 19,
                        outlier.size = 1.5, outlier.stroke = 0.5,
                        notch = FALSE, notchwidth = 0.5, varwidth = FALSE) {

    common <- data.frame(
      colour = data$colour,
      size = data$size,
      linetype = data$linetype,
      fill = alpha(data$fill, data$alpha),
      group = data$group,
      stringsAsFactors = FALSE
    )
    if( !is.null(data$tooltip) )
      common$tooltip <- as.character(data$tooltip)
    if( !is.null(data$onclick) )
      common$onclick <- as.character(data$onclick)
    if( !is.null(data$data_id) )
      common$data_id <- as.character(data$data_id)

    whiskers <- data.frame(
      x = data$x,
      xend = data$x,
      y = c(data$upper, data$lower),
      yend = c(data$ymax, data$ymin),
      alpha = NA,
      common,
      stringsAsFactors = FALSE
    )

    box <- data.frame(
      xmin = data$xmin,
      xmax = data$xmax,
      ymin = data$lower,
      y = data$middle,
      ymax = data$upper,
      ynotchlower = ifelse(notch, data$notchlower, NA),
      ynotchupper = ifelse(notch, data$notchupper, NA),
      notchwidth = notchwidth,
      alpha = data$alpha,
      common,
      stringsAsFactors = FALSE
    )

    if (!is.null(data$outliers) && length(data$outliers[[1]] >= 1)) {
      outliers <- data.frame(
        y = data$outliers[[1]],
        x = data$x[1],
        tooltip = formatC(data$outliers[[1]]),
        colour = outlier.colour %||% data$colour[1],
        shape = outlier.shape %||% data$shape[1],
        size = outlier.size %||% data$size[1],
        stroke = outlier.stroke %||% data$stroke[1],
        fill = NA,
        alpha = NA,
        stringsAsFactors = FALSE
      )
      outliers_grob <- GeomInteractivePoint$draw_panel(outliers, panel_scales, coord)
    } else {
      outliers_grob <- NULL
    }

    setGrobName("geom_boxplot_interactive", grobTree(
      outliers_grob,
      GeomInteractiveSegment$draw_panel(whiskers, panel_scales, coord),
      GeomInteractiveCrossbar$draw_panel(box, fatten = fatten, panel_scales, coord)
    ))
  },

  draw_key = draw_key_boxplot,

  default_aes = aes(weight = 1, colour = "grey20", fill = "white", size = 0.5,
                    alpha = NA, shape = 19, linetype = "solid",
                    tooltip = NULL, onclick = NULL, data_id = NULL),

  required_aes = c("x", "lower", "upper", "middle", "ymin", "ymax")
)



#' @importFrom ggplot2 GeomErrorbar
GeomInteractiveCrossbar <- ggproto("GeomInteractiveCrossbar", Geom,
  setup_data = function(data, params) {
    GeomErrorbar$setup_data(data, params)
  },

  default_aes = aes(colour = "black", fill = NA, size = 0.5, linetype = 1,
                    alpha = NA, tooltip = NULL, onclick = NULL, data_id = NULL),

  required_aes = c("x", "y", "ymin", "ymax"),

  draw_key = draw_key_crossbar,

  draw_panel = function(data, panel_scales, coord, fatten = 2.5, width = NULL) {
    middle <- transform(data, x = xmin, xend = xmax, yend = y, size = size * fatten, alpha = NA)

      has_notch <- !is.null(data$ynotchlower) && !is.null(data$ynotchupper) &&
      !is.na(data$ynotchlower) && !is.na(data$ynotchupper)

    if (has_notch) {
      if (data$ynotchlower < data$ymin  ||  data$ynotchupper > data$ymax)
        message("notch went outside hinges. Try setting notch=FALSE.")

      notchindent <- (1 - data$notchwidth) * (data$xmax - data$xmin) / 2

      middle$x <- middle$x + notchindent
      middle$xend <- middle$xend - notchindent
      box <- data.frame(
        x = c(
          data$xmin, data$xmin, data$xmin + notchindent, data$xmin, data$xmin,
          data$xmax, data$xmax, data$xmax - notchindent, data$xmax, data$xmax,
          data$xmin
        ),
        y = c(
          data$ymax, data$ynotchupper, data$y, data$ynotchlower, data$ymin,
          data$ymin, data$ynotchlower, data$y, data$ynotchupper, data$ymax,
          data$ymax
        ),
        alpha = data$alpha,
        colour = data$colour,
        size = data$size,
        linetype = data$linetype, fill = data$fill,
        group = seq_len(nrow(data)),
        stringsAsFactors = FALSE
      )
    } else {
      # No notch
      box <- data.frame(
        x = c(data$xmin, data$xmin, data$xmax, data$xmax, data$xmin),
        y = c(data$ymax, data$ymin, data$ymin, data$ymax, data$ymax),
        alpha = data$alpha,
        colour = data$colour,
        size = data$size,
        linetype = data$linetype,
        fill = data$fill,
        group = seq_len(nrow(data)), # each bar forms it's own group
        stringsAsFactors = FALSE
      )
    }

    if( !is.null(data$tooltip) )
      box$tooltip <- as.character(data$tooltip)
    if( !is.null(data$onclick) )
      box$onclick <- as.character(data$onclick)
    if( !is.null(data$data_id) )
      box$data_id <- as.character(data$data_id)


      setGrobName("geom_crossbar", gTree(children = gList(
      GeomInteractivePolygon$draw_panel(box, panel_scales, coord),
      GeomInteractiveSegment$draw_panel(middle, panel_scales, coord)
    )))
  }
)
