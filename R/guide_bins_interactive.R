#' @title Create interactive bins guide
#' @description
#' The guide is based on [guide_bins()].
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
  guide <- guide_interactive(guide_legend, "interactive_bins", ...)
  if (!inherits(guide, "Guide")) {
    return(guide)
  } else {
    ggproto_legend_interactive(guide)
  }
}


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

#' @export
guide_geom.interactive_bins <- function(guide,
                                        layers,
                                        default_mapping) {
  check_guide_key_geoms(NextMethod())
}
