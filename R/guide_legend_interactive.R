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
  default_mapping <- append_aes(default_mapping, list(data_id = NULL, tooltip = NULL, onclick = NULL))
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
  if( !is.null(scale$data_id) && length(breaks) > 0 ){
    key$data_id <- scale$data_id[breaks]
  } else if(!is.null(scale$data_id)) {
    key$data_id <- scale$data_id
  }
  if( !is.null(scale$tooltip) && length(breaks) > 0 ){
    key$tooltip <- scale$tooltip[breaks]
  } else if(!is.null(scale$tooltip)) {
    key$tooltip <- scale$tooltip
  }
  if( !is.null(scale$onclick) && length(breaks) > 0 ){
    key$onclick <- scale$onclick[breaks]
  } else if(!is.null(scale$onclick)) {
    key$onclick <- scale$onclick
  }

  zz$key <- key
  zz
}

