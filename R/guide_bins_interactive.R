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
      params <- interactive_guide_train(params, scale, parsed$all_breaks)
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
  build_labels = function(key, elements, params) {
    grobs <- GuideBins$build_labels(key, elements, params)
    if (inherits(key$.label, "interactive_label") && !all(params$show.limits)) {
      valid_ind <- setdiff(
        seq_len(nrow(key)),
        c(1, nrow(key))[!params$show.limits]
      )
      idata <- grobs$labels$children[[1]]$.interactive
      idata <- lapply(idata, function(a) {
        a[valid_ind]
      })
      grobs$labels$children[[1]]$.interactive <- idata
    }
    grobs
  }
)
