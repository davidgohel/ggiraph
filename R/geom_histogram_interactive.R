#' @title interactive boxplot
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_histogram}}.
#' See the documentation for those functions for more details.
#'
#' This interactive version is only providing a single tooltip per
#' group of data (same for \code{data_id}). It means it is only possible
#' to associate a single tooltip to a set of bins.
#'
#' @seealso \code{\link{girafe}}
#' @inheritParams ggplot2::geom_histogram
#' @export
geom_histogram_interactive <- function(mapping = NULL, data = NULL,
                           stat = "bin", position = "stack",
                           ...,
                           binwidth = NULL,
                           bins = NULL,
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE) {

  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomInteractiveBar,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      binwidth = binwidth,
      bins = bins,
      na.rm = na.rm,
      pad = FALSE,
      ...
    )
  )
}
