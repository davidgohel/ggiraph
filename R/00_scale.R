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
#' @importFrom scales seq_gradient_pal
#' @title Create your own interactive gradient scale
#' @description The scale is based on \code{\link[ggplot2]{scale_colour_gradient}}.
#' These functions allow you to make interactive legends associated with interactive
#' layers.
#' @inheritParams ggplot2::scale_colour_gradient
#' @param tooltip tooltip associated with keys, one per key, a named vector
#' @param onclick javascript actions to execute when a key is clicked, one per key, a named vector
#' @param data_id identifiers to associate with key, one per key, a named vector
#' @name scale_gradient_interactive
scale_colour_gradient_interactive <- function(..., low = "#132B43", high = "#56B1F7", space = "Lab",
                                              na.value = "grey50", guide = "colourbar", aesthetics = "colour",
                                              data_id = NULL, onclick = NULL, tooltip = NULL) {
  zz <- continuous_scale(aesthetics, "gradient", seq_gradient_pal(low, high, space),
                         na.value = na.value, guide = guide, ...)

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
#' @rdname scale_gradient_interactive
scale_fill_gradient_interactive <- function(..., low = "#132B43", high = "#56B1F7", space = "Lab",
                                              na.value = "grey50", guide = "colourbar", aesthetics = "fill",
                                              data_id = NULL, onclick = NULL, tooltip = NULL) {
  zz <- continuous_scale(aesthetics, "gradient", seq_gradient_pal(low, high, space),
                         na.value = na.value, guide = guide, ...)

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



