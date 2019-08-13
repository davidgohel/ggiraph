#' @export
scale_colour_manual_interactive <-
  function(..., values, data_id = NULL, tooltip = NULL,
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
  zz$guide <- paste0(zz$guide, "_interactive")

  zz
  }

#' @export
scale_color_manual_interactive <- scale_colour_manual_interactive


#' @export
scale_fill_manual_interactive <- function(..., values, data_id = NULL, tooltip = NULL, aesthetics = "fill") {
  zz <- scale_fill_manual(..., values = values, aesthetics = aesthetics)
  scale_interactive <- FALSE

  if( !is.null(data_id) ){
    zz$data_id <- data_id
    scale_interactive <- TRUE
  }
  if( !is.null(tooltip) ){
    zz$tooltip <- tooltip
    scale_interactive <- TRUE
  }

  zz$guide <- paste0(zz$guide, "_interactive")

  zz
}

#' @export
guide_legend_interactive <- function(...) {
  zz <- guide_legend(...)

  class(zz) <- c("legend_interactive", class(zz))
  zz
}

#' @export
#' @importFrom ggplot2 guide_train
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

  zz$key <- key
  zz
}

draw_key_point_interactive <- function(data, params, size) {

  if (is.null(data$shape)) {
    data$shape <- 19
  }
  else if (is.character(data$shape)) {
    data$shape <- ggplot2:::translate_shape_string(data$shape)
  }
  interactive_points_grob(x = 0.5, y = 0.5,
                          tooltip = data$tooltip,
                          onclick = data$onclick,
                          data_id = data$data_id,
                          pch = data$shape,
                          gp = gpar(col = alpha(data$colour %||% "black", data$alpha),
                                    fill = alpha(data$fill %||% "black", data$alpha),
                                    fontsize = (data$size %||% 1.5) * .pt + (data$stroke %||% 0.5) * .stroke/2,
                                    lwd = (data$stroke %||% 0.5) * .stroke/2),
                          cl = "interactive_key_points_grob"
                          )
}
