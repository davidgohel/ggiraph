#' @title Create interactive violin plot
#'
#' @description
#' The geometry is based on [ggplot2::geom_violin()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive violin plot -------
#' @example examples/geom_violin_interactive.R
#' @seealso [girafe()]
#' @export
geom_violin_interactive <- function(...) {
  layer_interactive(geom_violin, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveViolin <- ggproto(
  "GeomInteractiveViolin",
  GeomViolin,
  default_aes = add_default_interactive_aes(GeomViolin),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(
    self,
    data,
    ...,
    draw_quantiles = NULL,
    flipped_aes = FALSE,
    .ipar = IPAR_NAMES
  ) {
    data <- flip_data(data, flipped_aes)
    # Find the points for the line to go all the way around
    data <- transform(
      data,
      xminv = x - violinwidth * (x - xmin),
      xmaxv = x + violinwidth * (xmax - x)
    )

    # Make sure it's sorted properly to draw the outline
    newdata <- rbind(
      transform(data, x = xminv)[order(data$y), ],
      transform(data, x = xmaxv)[order(data$y, decreasing = TRUE), ]
    )

    # Close the polygon: set first and last point the same
    # Needed for coord_polar and such
    newdata <- rbind(newdata, newdata[1, ])
    newdata <- flip_data(newdata, flipped_aes)

    # Draw quantiles if requested, so long as there is non-zero y range
    if (length(draw_quantiles) > 0 & !scales::zero_range(range(data$y))) {
      if (!(all(draw_quantiles >= 0) && all(draw_quantiles <= 1))) {
        abort("`draw_quantiles must be between 0 and 1")
      }

      # Compute the quantile segments and combine with existing aesthetics
      quantiles <- create_quantile_segment_frame(data, draw_quantiles)
      aesthetics <- data[
        rep(1, nrow(quantiles)),
        setdiff(names(data), c("x", "y", "group")),
        drop = FALSE
      ]
      aesthetics$alpha <- rep(1, nrow(quantiles))
      both <- cbind(quantiles, aesthetics)
      both <- both[!is.na(both$group), , drop = FALSE]
      both <- flip_data(both, flipped_aes)
      quantile_grob <- if (nrow(both) == 0) {
        zeroGrob()
      } else {
        GeomInteractivePath$draw_panel(both, ..., .ipar = .ipar)
      }

      ggname(
        "geom_violin",
        grobTree(
          GeomInteractivePolygon$draw_panel(newdata, ..., .ipar = .ipar),
          quantile_grob
        )
      )
    } else {
      ggname(
        "geom_violin",
        GeomInteractivePolygon$draw_panel(newdata, ..., .ipar = .ipar)
      )
    }
  }
)

create_quantile_segment_frame <- function(data, draw_quantiles) {
  dens <- cumsum(data$density) / sum(data$density)
  ecdf <- stats::approxfun(dens, data$y, ties = "ordered")
  ys <- ecdf(draw_quantiles) # these are all the y-values for quantiles

  # Get the violin bounds for the requested quantiles.
  violin.xminvs <- (stats::approxfun(data$y, data$xminv))(ys)
  violin.xmaxvs <- (stats::approxfun(data$y, data$xmaxv))(ys)

  # We have two rows per segment drawn. Each segment gets its own group.
  data_frame0(
    x = vctrs::vec_interleave(violin.xminvs, violin.xmaxvs),
    y = rep(ys, each = 2),
    group = rep(ys, each = 2)
  )
}
