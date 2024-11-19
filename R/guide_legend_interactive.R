#' @title Create interactive legend guide
#' @description
#' The guide is based on [ggplot2::guide_legend()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for interactive scale and interactive guide functions
#' @examples
#' # add interactive discrete legend guide to a ggplot -------
#' @example examples/scale_manual_guide_legend_discrete_interactive.R
#' @examples
#' # add interactive continuous legend guide to a ggplot -------
#' @example examples/scale_viridis_guide_legend_continuous_interactive.R
#' @seealso [interactive_parameters], [girafe()]
#' @export
guide_legend_interactive <- function(...) {
  guide_interactive(guide_legend, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GuideInteractiveLegend <- ggproto(
  "GuideInteractiveLegend", GuideLegend,
  train = function(self, params = self$params, scale, aesthetic = NULL, ...) {
    parent <- ggproto_parent(GuideLegend, self)
    params <- parent$train(params = params, scale = scale, aesthetic = aesthetic, ...)
    if (!is.null(params) && is.data.frame(params$key) && nrow(params$key)) {
      params <- interactive_guide_train(params, scale, breaks = params$key$.value)
    }
    params
  },
  override_elements = function(params, elements, theme) {
    elements <- GuideLegend$override_elements(params, elements, theme)
    interactive_guide_override_elements(elements)
  },
  build_decor = function(decor, grobs, elements, params) {
    decor <- interactive_guide_build_decor(decor, params)
    GuideLegend$build_decor(decor, grobs, elements, params)
  },
  build_labels = function(key, elements, params) {
    if (inherits(key$.label, "interactive_label")) {
      # convert to individual labels
      labels <- key$.label
      lbl_ipar <- get_ipar(labels)
      lbl_ip <- transpose(get_interactive_data(labels))
      extra_interactive_params <- setdiff(lbl_ipar, IPAR_NAMES)
      labels <- lapply(seq_along(labels), function(i) {
        args <- c(list(
          label = labels[[i]],
          extra_interactive_params = extra_interactive_params
        ), lbl_ip[[i]])
        do.call(label_interactive, args)
      })
      key$.label <- labels
    }
    # call super
    GuideLegend$build_labels(key, elements, params)
  }
)
