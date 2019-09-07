#' @export
#' @title interactive legend guide
#' @description an interactive legend guide.
#' See \code{\link[ggplot2]{guide_legend}} for more details.
#' @param ... arguments passed to guide_legend.
guide_legend_interactive <- function(...) {
  zz <- guide_legend(...)
  class(zz) <- c("legend_interactive", class(zz))
  zz
}
#' @export
guide_geom.legend_interactive <- function(guide, layers, default_mapping){
  default_mapping <- append_aes(default_mapping, IPAR_DEFAULTS)
  NextMethod()
}

#' @export
#' @inheritParams ggplot2::guide_train
#' @param scale,aesthetic other parameters used by guide_train
#' @title methods for interactive legend guide
#' @description These functions should not be used by the end users.
guide_train.legend_interactive <- function(guide, scale, aesthetic = NULL) {
  zz <- NextMethod()
  if( is.null(zz) ) return(zz)

  key <- zz$key
  breaks <- scale$get_breaks()
  rows = NULL
  if (length(breaks) > 0) {
    rows = breaks
  }
  key <- copy_interactive_attrs(scale, key, forceChar = FALSE, rows = rows)
  zz$key <- key
  zz
}

