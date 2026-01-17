#' @title Create interactive bins guide
#' @description
#' The guide is based on [ggplot2::guide_bins()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @examples
#' # add interactive bins guide to a ggplot -------
#' @example examples/scale_viridis_guide_bins_interactive.R
#' @seealso [interactive_parameters], [girafe()]
#' @export
guide_bins_interactive <- function(...) {
  guide_interactive(guide_bins, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GuideInteractiveBins <- ggproto(
  "GuideInteractiveBins",
  GuideBins,
  train = function(self, params = self$params, scale, aesthetic = NULL, ...) {
    parent <- ggproto_parent(GuideBins, self)
    params <- parent$train(
      params = params,
      scale = scale,
      aesthetic = aesthetic,
      ...
    )
    if (!is.null(params) && is.data.frame(params$key) && nrow(params$key)) {
      parsed <- interactive_guide_parse_binned_breaks(scale, params)
      breaks <- parsed$all_breaks
      # ggplot2 >= 4.0
      # Pass label_breaks separately from breaks to match what scale$get_labels()
      # will return. This prevents length mismatch warnings in interactive_guide_train.
      label_breaks <- parsed$breaks
      show.limits <- params$show.limits %||% scale$show.limits %||% FALSE
      # ggplot2 >= 4.0: show.limits can be a length-2 vector, use any()
      if (
        any(show.limits) &&
          !(is.character(scale$labels) || is.numeric(scale$labels))
      ) {
        label_breaks <- parsed$all_breaks
      }
      params <- interactive_guide_train(
        params,
        scale,
        breaks,
        label_breaks = label_breaks
      )
    }
    params
  },
  override_elements = function(params, elements, theme) {
    elements <- GuideBins$override_elements(params, elements, theme)
    interactive_guide_override_elements(elements)
  },
  build_decor = function(decor, grobs, elements, params) {
    decor <- interactive_guide_build_decor(decor, params)
    GuideBins$build_decor(decor, grobs, elements, params)
  },
  # In ggplot2 4.0, GuideBins$build_labels calls validate_labels() which
  # processes lists with unlist(), stripping the 'interactive_label' class.
  # We override build_labels to convert the single interactive_label object
  # into a list of individual label_interactive objects BEFORE calling parent.
  build_labels = function(key, elements, params) {
    if (inherits(key$.label, "interactive_label")) {
      labels <- key$.label
      lbl_ipar <- get_ipar(labels)
      lbl_ip <- transpose(get_interactive_data(labels))
      extra_interactive_params <- setdiff(lbl_ipar, IPAR_NAMES)
      labels <- lapply(seq_along(labels), function(i) {
        args <- c(
          list(
            label = labels[[i]],
            extra_interactive_params = extra_interactive_params
          ),
          lbl_ip[[i]]
        )
        do.call(label_interactive, args)
      })
      key$.label <- labels
    }
    GuideBins$build_labels(key, elements, params)
  }
)
