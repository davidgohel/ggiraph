#' @export
#' @title Create your own interactive discrete scale
#' @description The scale is based on \code{\link[ggplot2]{scale_colour_manual}}.
#' These functions allow you to make interactive legends associated with interactive
#' layers.
#' @inheritParams ggplot2::scale_colour_manual
#' @param tooltip tooltip associated with keys, one per key, a named vector
#' @param onclick javascript actions to execute when a key is clicked, one per key, a named vector
#' @param data_id identifiers to associate with key, one per key, a named vector
#' @name scale_manual_interactive
scale_colour_manual_interactive <-
  function(..., values, data_id = NULL, onclick = NULL, tooltip = NULL,
           aesthetics = "colour") {
    zz <- scale_colour_manual(..., values = values, aesthetics = aesthetics)

    scale_interactive <- FALSE

    if( !is.null(data_id) ){
      zz$data_id <- data_id
      scale_interactive <- TRUE
    }
    if( !is.null(tooltip) ){
      zz$tooltip <- tooltip
      scale_interactive <- TRUE
    }
    if( !is.null(onclick) ){
      zz$onclick <- onclick
      scale_interactive <- TRUE
    }
    zz$guide <- paste0(zz$guide, "_interactive")

    zz
  }

#' @export
#' @rdname scale_manual_interactive
scale_fill_manual_interactive <- function(..., values, data_id = NULL, onclick = NULL, tooltip = NULL, aesthetics = "fill") {
  zz <- scale_fill_manual(..., values = values, aesthetics = aesthetics)

  if( !is.null(data_id) ){
    zz$data_id <- data_id
  }
  if( !is.null(tooltip) ){
    zz$tooltip <- tooltip
  }
  if( !is.null(onclick) ){
    zz$onclick <- onclick
  }

  zz$guide <- paste0(zz$guide, "_interactive")

  zz
}

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

