#' @include girafe_options.R fonts.R utils_css.R
girafe_global <- new.env(parent = emptyenv())

css_default_hover <- girafe_css_bicolor(primary = "orange", secondary = "black")
css_default_selection <- girafe_css_bicolor(
  primary = "red",
  secondary = "black"
)

default_girafe_settings <- list(
  opts_sizing = opts_sizing(width = 1),
  opts_tooltip = opts_tooltip(
    css = "padding:5px;background:black;color:white;border-radius:2px;text-align:left;",
    offx = 10,
    offy = 10
  ),
  opts_hover = opts_hover(css = css_default_hover, reactive = TRUE),
  opts_hover_key = opts_hover_key(css = css_default_hover, reactive = TRUE),
  opts_hover_theme = opts_hover_theme(css = css_default_hover, reactive = TRUE),
  opts_hover_inv = opts_hover_inv(css = ""),
  opts_selection = opts_selection(css = css_default_selection),
  opts_selection_inv = opts_selection_inv(),
  opts_selection_key = opts_selection_key(css = css_default_selection),
  opts_selection_theme = opts_selection_theme(css = css_default_selection),
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
#'
#' Only the arguments given to the `opts_*()` functions replace the current
#' defaults, as with the `options` argument of [girafe()]: after
#' `set_girafe_defaults(opts_toolbar = opts_toolbar(pngname = "plot"))`,
#' a call to `set_girafe_defaults(opts_toolbar = opts_toolbar(position = "top"))`
#' keeps `pngname = "plot"`.
#' @return the previous defaults, invisibly.
#' @family girafe animation options
#' @param fonts deprecated, it never had any effect: use the `font_set`
#' argument of [girafe()] to choose the fonts.
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
  opts_toolbar = NULL
) {
  if (!is.null(fonts)) {
    cli::cli_warn(c(
      "!" = "The {.arg fonts} argument of {.fn set_girafe_defaults} is deprecated and has no effect.",
      "i" = "Use the {.arg font_set} argument of {.fn girafe} to choose the fonts."
    ))
  }
  new_opts <- list(
    opts_sizing = opts_sizing,
    opts_tooltip = opts_tooltip,
    opts_hover = opts_hover,
    opts_hover_key = opts_hover_key,
    opts_hover_inv = opts_hover_inv,
    opts_hover_theme = opts_hover_theme,
    opts_selection = opts_selection,
    opts_selection_inv = opts_selection_inv,
    opts_selection_key = opts_selection_key,
    opts_selection_theme = opts_selection_theme,
    opts_zoom = opts_zoom,
    opts_toolbar = opts_toolbar
  )
  new_opts <- Filter(Negate(is.null), new_opts)

  # as with the `options` of girafe(), only the arguments given to the
  # opts_*() functions replace the current defaults
  old_defaults <- girafe_defaults()
  defaults <- old_defaults
  for (name in names(new_opts)) {
    defaults[[name]] <- merge_single_opts(defaults[[name]], new_opts[[name]])
  }
  girafe_global$defaults <- defaults
  invisible(old_defaults)
}

#' @export
#' @title Re-init animation defaults options
#'
#' @description Re-init all defaults options with the package defaults.
#' @family girafe animation options
init_girafe_defaults <- function() {
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
#' 'opts_sizing', 'opts_tooltip', 'opts_hover', 'opts_hover_key',
#' 'opts_hover_inv', 'opts_hover_theme', 'opts_selection',
#' 'opts_selection_inv', 'opts_selection_key', 'opts_selection_theme',
#' 'opts_zoom', 'opts_toolbar'.
#' @examples
#' girafe_defaults()
#' @return a list containing default values or an
#' element selected with argument `name`.
#' @family girafe animation options
girafe_defaults <- function(name = NULL) {
  x <- girafe_global$defaults
  if (!is.null(name) && !is_valid_string_non_empty(name)) {
    abort("`name` must be a non-empty scalar character", call = NULL)
  } else if (!is.null(name) && is_valid_string_non_empty(name)) {
    x[[name]]
  } else {
    x
  }
}

default_width <- function(default = 6) {
  if (isTRUE(getOption('knitr.in.progress'))) {
    knitr::opts_current$get("fig.width")
  } else {
    default
  }
}
default_height <- function(default = 5) {
  if (isTRUE(getOption('knitr.in.progress'))) {
    knitr::opts_current$get("fig.height")
  } else {
    default
  }
}
