
outlier_ipar <- paste0("outlier.", IPAR_NAMES)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
StatInteractiveBoxplot <- ggproto(
  "StatInteractiveBoxplot", StatBoxplot,
  compute_group = function(data, scales, width = NULL, na.rm = FALSE,
                           coef = 1.5, flipped_aes = FALSE) {
    # compute boxplot data
    df <- StatBoxplot$compute_group(data, scales,
                                    width = width, na.rm = na.rm,
                                    coef = coef, flipped_aes = flipped_aes
    )
    # add outlier aesthetics
    if (length(df$outliers[[1]])) {
      outlier_indices <- which(data$y %in% df$outliers[[1]])
      outlier_colnames <- intersect(colnames(data), outlier_ipar)
      if (length(outlier_colnames)) {
        for (name in outlier_colnames) {
          df[[name]] <- list(data[[name]][outlier_indices])
        }
      }
    }
    df
  }
)

#' @title Create interactive boxplot
#'
#' @description
#' The geometry is based on [geom_boxplot()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @details
#' You can supply `interactive parameters` for the outlier points by prefixing them
#' with `outlier.` prefix. For example: aes(outlier.tooltip = 'bla', outlier.data_id = 'blabla').
#'
#' IMPORTANT: when supplying outlier interactive parameters,
#' the correct `group` aesthetic *must* be also supplied. Otherwise the default group calculation
#' will be incorrect, which will result in an incorrect plot.
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive boxplot -------
#' @example examples/geom_boxplot_interactive.R
#' @seealso [girafe()]
#' @export
geom_boxplot_interactive <- function(...) {
  args <- list(...)
  if ("extra_interactive_params" %in% names(args)) {
    args$extra_interactive_params <- c(args$extra_interactive_params, outlier_ipar)
  } else {
    args$extra_interactive_params <- outlier_ipar
  }
  if (!"stat" %in% names(args)) {
    args$stat <- StatInteractiveBoxplot
  }
  args$layer_func <- geom_boxplot
  do.call(layer_interactive, args)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveBoxplot <- ggproto(
  "GeomInteractiveBoxplot",
  GeomBoxplot,
  default_aes = append_aes(
    GeomBoxplot$default_aes,
    c(IPAR_DEFAULTS, rlang::set_names(IPAR_DEFAULTS, outlier_ipar))
  ),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
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
                        flipped_aes = FALSE,
                        .ipar = IPAR_NAMES) {
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

    .ipar <- setdiff(.ipar, outlier_ipar)
    common <- copy_interactive_attrs(data, common, ipar = .ipar)

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
        colour = outlier.colour %||% data$colour[1],
        fill = outlier.fill %||% data$fill[1],
        shape = outlier.shape %||% data$shape[1],
        size = outlier.size %||% data$size[1],
        stroke = outlier.stroke %||% data$stroke[1],
        fill = NA,
        alpha = outlier.alpha %||% data$alpha[1]
      )
      outlier_colnames <- intersect(colnames(data), outlier_ipar)
      if (length(outlier_colnames)) {
        for (name in outlier_colnames) {
          unprefixed_name <- sub("outlier.", "", name)
          outl[[unprefixed_name]] <- data[[name]][[1]]
        }
      }

      outliers <- new_data_frame(
        outl,
        n = length(data$outliers[[1]])
      )
      outliers <- flip_data(outliers, flipped_aes)
      outliers_grob <-
        GeomInteractivePoint$draw_panel(outliers, panel_params, coord, .ipar = .ipar)
    } else {
      outliers_grob <- NULL
    }

    ggname(
      "geom_boxplot_interactive",
      grobTree(
        outliers_grob,
        GeomInteractiveSegment$draw_panel(whiskers, panel_params, coord, .ipar = .ipar),
        GeomInteractiveCrossbar$draw_panel(box, fatten = fatten, panel_params, coord, flipped_aes = flipped_aes, .ipar = .ipar)
      )
    )
  }
)
