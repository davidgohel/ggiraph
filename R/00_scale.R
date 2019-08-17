#' @export
#' @title Create your own interactive discrete scale
#' @description The scale is based on \code{\link[ggplot2]{scale_colour_manual}}.
#' These functions allow you to make interactive legend's keys associated with an
#' interactive layer.
#'
#' For a discrete interactive scale, a single tooltip, data_id and onclick
#' is available for each level. The primary goal when these function has been
#' written was to enable a click on a legend's key in a shiny application.
#' @inheritParams ggplot2::scale_colour_manual
#' @param tooltip a named character vector where names are level values and values are
#' an associated tooltip value, text and html are supported.
#' @param onclick a named character vector where names are level values and values are
#' an associated JavaScript action. Action will be executed when a key will be clicked
#' @param data_id a named character vector where names are level values and values are
#' identifiers. Identifiers are available as reactive input values in shiny applications.
#' @name scale_manual_interactive
#' @family interactive scale
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
scale_color_manual_interactive <- scale_colour_manual_interactive

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
#' These functions allow you to make interactive legends associated with a
#' layer.
#'
#' For a continuous interactive scale, only single tooltip, data_id and onclick
#' is available. The primary goal when this function has been written was to enable
#' a click on a legend in a shiny application.
#' @note
#' It is not planned to provide a more advanced interactivity within shiny applications
#' but contributions are welcome.
#' @inheritParams ggplot2::scale_colour_gradient
#' @param tooltip a single character value, the tooltip value, text and html are supported.
#' @param onclick a single character value, associated JavaScript action. Action will be
#' executed when the legend will be clicked.
#' @param data_id a single character value, the identifier. Identifier is available
#' as a reactive input value in shiny applications.
#' @name scale_gradient_interactive
#' @family interactive scale
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
scale_color_gradient_interactive <- scale_colour_gradient_interactive

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


