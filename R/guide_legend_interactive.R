#' @title Create interactive legend guide
#' @description
#' The guide is based on [guide_legend()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @examples
#' # add interactive discrete legend guide to a ggplot -------
#' @example examples/scale_manual_guide_legend_discrete_interactive.R
#' @examples
#' # add interactive continuous legend guide to a ggplot -------
#' @example examples/scale_viridis_guide_legend_continuous_interactive.R
#' @seealso [interactive_parameters()], [girafe()]
#' @export
guide_legend_interactive <- function(...)
  guide_interactive(guide_legend, "interactive_legend", ...)

#' @export
#' @importFrom purrr imap
guide_train.interactive_legend <- function(guide,
                                           scale,
                                           aesthetic = NULL) {
  zz <- NextMethod()
  if (is.null(zz))
    return(zz)

  copy_interactive_attrs_from_scale(zz, scale)
}
