#' @title Create interactive continuous colour bar guide
#' @description
#' The guide is based on [ggplot2::guide_colourbar()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @examples
#' # add interactive colourbar guide to a ggplot -------
#' @example examples/scale_gradient_guide_colourbar_interactive.R
#' @seealso [interactive_parameters], [girafe()]
#' @export
guide_colourbar_interactive <- function(...) {
  guide_interactive(guide_colourbar, ...)
}

#' @export
#' @rdname guide_colourbar_interactive
guide_colorbar_interactive <- guide_colourbar_interactive

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GuideInteractiveColourbar <- ggproto(
  "GuideInteractiveColourbar",
  GuideColourbar,
  train = function(self, params = self$params, scale, aesthetic = NULL, ...) {
    parent <- ggproto_parent(GuideColourbar, self)
    params <- parent$train(
      params = params,
      scale = scale,
      aesthetic = aesthetic,
      ...
    )
    if (!is.null(params) && is.data.frame(params$key) && nrow(params$key)) {
      breaks <- Filter(is.finite, scale$get_breaks())
      label_breaks <- breaks
      if (isTRUE(params$raster)) {
        breaks <- 1
      } else {
        breaks <- params$decor$value
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
    elements <- GuideColourbar$override_elements(params, elements, theme)
    interactive_guide_override_elements(elements)
  },
  build_decor = function(decor, grobs, elements, params) {
    result <- GuideColourbar$build_decor(decor, grobs, elements, params)
    ipar <- get_ipar(params)
    idata <- get_interactive_data(params)
    if (length(idata)) {
      result$bar <- add_interactive_attrs(
        result$bar,
        idata,
        data_attr = "key-id",
        ipar = ipar
      )
    }
    result
  },
  # In ggplot2 4.0, GuideColourbar$build_labels calls validate_labels() which
  # processes lists with unlist(), stripping the 'interactive_label' class.
  # We override build_labels to convert the single interactive_label object
  # (containing multiple labels) into a list of individual label_interactive
  # objects BEFORE calling the parent method. Each individual label_interactive
  # preserves its interactive attributes when passed to element_grob().
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
    GuideColourbar$build_labels(key, elements, params)
  }
)
