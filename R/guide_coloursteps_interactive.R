#' @title Create interactive colorsteps guide
#' @description
#' The guide is based on [ggplot2::guide_coloursteps()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @examples
#' # add interactive coloursteps guide to a ggplot -------
#' @example examples/scale_viridis_guide_coloursteps_interactive.R
#' @seealso [interactive_parameters], [girafe()]
#' @export
guide_coloursteps_interactive <- function(...) {
  guide_interactive(
    guide_coloursteps,
    ...,
    interactive_guide = GuideInteractiveColoursteps
  )
}

#' @export
#' @rdname guide_coloursteps_interactive
guide_colorsteps_interactive <- guide_coloursteps_interactive

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GuideInteractiveColoursteps <- ggproto(
  "GuideInteractiveColoursteps",
  GuideColoursteps,
  train = function(self, params = self$params, scale, aesthetic = NULL, ...) {
    parent <- ggproto_parent(GuideColoursteps, self)
    params <- parent$train(
      params = params,
      scale = scale,
      aesthetic = aesthetic,
      ...
    )
    if (!is.null(params) && is.data.frame(params$key) && nrow(params$key)) {
      parsed <- interactive_guide_parse_binned_breaks(scale, params)
      breaks <- parsed$all_breaks
      label_breaks <- parsed$breaks
      if (params$even.steps || !is.numeric(parsed$scale_breaks)) {
        show.limits <- params$show.limits %||% scale$show.limits %||% FALSE
        # ggplot2 >= 4.0: show.limits can be a length-2 vector, use any()
        if (
          any(show.limits) &&
            !(is.character(scale$labels) || is.numeric(scale$labels))
        ) {
          label_breaks <- parsed$all_breaks
        }
      }
      params <- interactive_guide_train(
        params,
        scale,
        breaks,
        label_breaks = label_breaks,
        max_len = length(breaks) - 1
      )
    }
    params
  },
  override_elements = function(params, elements, theme) {
    elements <- GuideColoursteps$override_elements(params, elements, theme)
    interactive_guide_override_elements(elements)
  },
  build_decor = function(decor, grobs, elements, params) {
    GuideInteractiveColourbar$build_decor(decor, grobs, elements, params)
  },
  # Delegate to GuideInteractiveColourbar which handles interactive_label
  build_labels = function(key, elements, params) {
    GuideInteractiveColourbar$build_labels(key, elements, params)
  }
)
