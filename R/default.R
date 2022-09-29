#' @include girafe_options.R fonts.R utils_css.R
girafe_global <- new.env(parent = emptyenv())

default_girafe_settings <- list(
  fonts = default_fontname(),
  opts_sizing = opts_sizing(width = 1),
  opts_tooltip = opts_tooltip(
    css = "padding:5px;background:black;color:white;border-radius:2px;text-align:left;",
    offx = 10, offy = 10),
  opts_hover = opts_hover(),
  opts_hover_key = opts_hover_key(),
  opts_hover_theme = opts_hover_theme(),
  opts_hover_inv = opts_hover_inv(),
  opts_selection = opts_selection(),
  opts_selection_inv = opts_selection_inv(),
  opts_selection_key = opts_selection_key(),
  opts_selection_theme = opts_selection_theme(),
  opts_zoom = opts_zoom(),
  opts_toolbar = opts_toolbar()
)

girafe_global$defaults <- default_girafe_settings


#' @export
#' @title Modify defaults girafe animation options
#'
#' @description girafe animation options (see [girafe_defaults()])
#' are automatically applied to every girafe you produce.
#' Use `set_girafe_defaults()` to override them. Use `init_girafe_defaults()`
#' to re-init all values with the package defaults.
#' @family girafe animation options
#' @param fonts default values for `fonts`, see argument `fonts`
#' of [dsvg()] function.
#' @param opts_sizing default values for [opts_sizing()] used
#' in argument `options` of `girafe()` function.
#' @param opts_tooltip default values for [opts_tooltip()] used
#' in argument `options` of `girafe()` function.
#' @param opts_hover default values for [opts_hover()] used in argument `options` of `girafe()` function.
#' @param opts_hover_key default values for [opts_hover_key()] used in argument `options` of `girafe()` function.
#' @param opts_hover_inv default values for [opts_hover_inv()] used in argument `options` of `girafe()` function.
#' @param opts_hover_theme default values for [opts_hover_theme()] used in argument `options` of `girafe()` function.
#' @param opts_selection default values for [opts_selection()] used in argument `options` of `girafe()` function.
#' @param opts_selection_inv default values for [opts_selection_inv()] used in argument `options` of `girafe()` function.
#' @param opts_selection_key default values for [opts_selection_key()] used in argument `options` of `girafe()` function.
#' @param opts_selection_theme default values for [opts_selection_theme()] used in argument `options` of `girafe()` function.
#' @param opts_zoom default values for [opts_zoom()] used in argument `options` of `girafe()` function.
#' @param opts_toolbar default values for [opts_toolbar()] used in argument `options` of `girafe()` function.
#' @examples
#' library(ggplot2)
#'
#' set_girafe_defaults(
#'   opts_hover = opts_hover(css = "r:10px;"),
#'   opts_hover_inv = opts_hover_inv(),
#'   opts_sizing = opts_sizing(rescale = FALSE, width = .8),
#'   opts_tooltip = opts_tooltip(opacity = .7,
#'                               offx = 20, offy = -10,
#'                               use_fill = TRUE, use_stroke = TRUE,
#'                               delay_mouseout = 1000),
#'   opts_toolbar = opts_toolbar(position = "top", saveaspng = FALSE),
#'   opts_zoom = opts_zoom(min = .8, max = 7)
#' )
#'
#' init_girafe_defaults()
set_girafe_defaults <- function(
    fonts = NULL,
    opts_sizing = NULL,
    opts_tooltip = NULL,
    opts_hover = NULL,
    opts_hover_key = NULL,
    opts_hover_inv = NULL,
    opts_hover_theme = NULL,
    opts_selection = NULL,
    opts_selection_inv = NULL,
    opts_selection_key = NULL,
    opts_selection_theme = NULL,
    opts_zoom = NULL,
    opts_toolbar = NULL){

  x <- list()

  if( !is.null(fonts) ){
    x$fonts <- fonts
  }
  if( !is.null(opts_sizing) ){
    x$opts_sizing <- opts_sizing
  }
  if( !is.null(opts_tooltip) ){
    x$opts_tooltip <- opts_tooltip
  }
  if( !is.null(opts_hover) ){
    x$opts_hover <- opts_hover
  }
  if( !is.null(opts_hover_inv) ){
    x$opts_hover_inv <- opts_hover_inv
  }
  if( !is.null(opts_hover_key) ){
    x$opts_hover_key <- opts_hover_key
  }
  if( !is.null(opts_hover_theme) ){
    x$opts_hover_theme <- opts_hover_theme
  }

  if( !is.null(opts_selection) ){
    x$opts_selection <- opts_selection
  }
  if( !is.null(opts_selection_inv) ){
    x$opts_selection_inv <- opts_selection_inv
  }
  if( !is.null(opts_selection_key) ){
    x$opts_selection_key <- opts_selection_key
  }
  if( !is.null(opts_selection_theme) ){
    x$opts_selection_theme <- opts_selection_theme
  }

  if( !is.null(opts_zoom) ){
    x$opts_zoom <- opts_zoom
  }
  if( !is.null(opts_toolbar) ){
    x$opts_toolbar <- opts_toolbar
  }
  girafe_defaults <- girafe_defaults()
  girafe_new_defaults <- modifyList(girafe_defaults, x)
  girafe_global$defaults <- girafe_new_defaults
  invisible(girafe_defaults)
}

#' @export
#' @title Re-init animation defaults options
#'
#' @description Re-init all defaults options with the package defaults.
#' @family girafe animation options
init_girafe_defaults <- function(){
  x <- default_girafe_settings
  girafe_global$defaults <- x
  class(x) <- "girafe_defaults"
  invisible(x)
}


#' @export
#' @title Get girafe defaults formatting properties
#'
#' @description The current formatting properties
#' are automatically applied to every girafe you produce.
#' These default values are returned by this function.
#' @param name optional, option's name to return, one of
#' 'fonts', 'opts_sizing', 'opts_tooltip', 'opts_hover', 'opts_hover_key',
#' 'opts_hover_inv', 'opts_hover_theme', 'opts_selection',
#' 'opts_selection_inv', 'opts_selection_key', 'opts_selection_theme',
#' 'opts_zoom', 'opts_toolbar'.
#' @examples
#' girafe_defaults()
#' @return a list containing default values or an
#' element selected with argument `name`.
#' @family girafe animation options
girafe_defaults <- function(name = NULL){
  x <- girafe_global$defaults
  if (!is.null(name) && !is_valid_string_non_empty(name)) {
    abort("`name` must be a non-empty scalar character", call = NULL)
  } else if (!is.null(name) && is_valid_string_non_empty(name)) {
    x[[name]]
  } else {
    x
  }
}

default_width <- function(default = 6){
  if (isTRUE(getOption('knitr.in.progress'))) {
    knitr::opts_current$get("fig.width")
  } else default
}
default_height <- function(default = 5){
  if (isTRUE(getOption('knitr.in.progress'))) {
    knitr::opts_current$get("fig.height")
  } else default
}

modifyList <- function (x, val, keep.null = FALSE) {
  stopifnot(is.list(x), is.list(val))
  xnames <- names(x)
  vnames <- names(val)
  vnames <- vnames[nzchar(vnames)]
  if (keep.null) {
    for (v in vnames) {
      x[v] <- if (v %in% xnames && is.list(x[[v]]) && is.list(val[[v]]))
        list(modifyList(x[[v]], val[[v]], keep.null = keep.null))
      else val[v]
    }
  }
  else {
    for (v in vnames) {
      x[[v]] <- if (v %in% xnames && is.list(x[[v]]) &&
                    is.list(val[[v]]))
        modifyList(x[[v]], val[[v]], keep.null = keep.null)
      else val[[v]]
    }
  }
  x
}

