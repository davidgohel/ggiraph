#' @title Create interactive smoothed conditional means
#'
#' @description
#' The geometry is based on [geom_smooth()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive bar -------
#' @example examples/geom_smooth_interactive.R
#' @seealso [girafe()]
#' @export
geom_smooth_interactive <- function(...)
  layer_interactive(geom_smooth, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveSmooth <- ggproto(
  "GeomInteractiveSmooth",
  GeomSmooth,
  default_aes = add_default_interactive_aes(GeomSmooth),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_group = function(data, panel_params, coord, lineend = "butt", linejoin = "round",
                        linemitre = 10, se = FALSE, flipped_aes = FALSE, .ipar = IPAR_NAMES) {
    ribbon <- transform(data, colour = NA)
    path <- transform(data, alpha = NA)

    ymin = flipped_names(flipped_aes)$ymin
    ymax = flipped_names(flipped_aes)$ymax
    has_ribbon <- se && !is.null(data[[ymax]]) && !is.null(data[[ymin]])

    gList(
      if (has_ribbon)
        GeomInteractiveRibbon$draw_group(ribbon, panel_params, coord, flipped_aes = flipped_aes, .ipar = .ipar),
      GeomInteractiveLine$draw_panel(path, panel_params, coord, lineend = lineend, linejoin = linejoin, linemitre = linemitre, .ipar = .ipar)
    )
  }
)
