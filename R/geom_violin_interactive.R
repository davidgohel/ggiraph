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
    quantile_gp = list(linetype = 0),
    flipped_aes = FALSE,
    .ipar = IPAR_NAMES
  ) {
    zz <- GeomViolin$draw_group(
      data = data,
      ...,
      quantile_gp = quantile_gp,
      flipped_aes = flipped_aes
    )
    if (inherits(zz, "polygon")) {
      zz <- add_interactive_attrs(zz, data, ipar = .ipar)
    } else if (inherits(zz, "gTree")) {
      zz$children[[1]] <- add_interactive_attrs(
        zz$children[[1]],
        data,
        ipar = .ipar
      )
    }
    zz
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
