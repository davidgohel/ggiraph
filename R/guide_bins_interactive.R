#' @title Create interactive bins guide
#' @description
#' The guide is based on [guide_bins()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @examples
#' # add interactive bins guide to a ggplot -------
#' @example examples/scale_viridis_guide_bins_interactive.R
#' @seealso [interactive_parameters()], [girafe()]
#' @export
guide_bins_interactive <- function(...)
  guide_interactive(guide_legend, "interactive_bins", ...)

#' @export
#' @importFrom purrr imap
guide_train.interactive_bins <- function(guide,
                                         scale,
                                         aesthetic = NULL) {
  zz <- NextMethod()
  if (is.null(zz))
    return(zz)

  copy_interactive_attrs_from_scale(zz, scale)
}
