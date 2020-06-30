#' @title Create interactive continuous colour bar guide
#' @description
#' The guide is based on [guide_colourbar()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @examples
#' # add interactive colourbar guide to a ggplot -------
#' @example examples/scale_gradient_guide_colourbar_interactive.R
#' @seealso [interactive_parameters()], [girafe()]
#' @export
guide_colourbar_interactive <- function(...)
  guide_interactive(guide_colourbar, "interactive_colourbar", ...)

#' @export
#' @rdname guide_colourbar_interactive
guide_colorbar_interactive <- guide_colourbar_interactive

#' @export
guide_train.interactive_colourbar <- function(guide,
                                              scale,
                                              aesthetic = NULL) {
  zz <- NextMethod()
  if (is.null(zz))
    return(zz)

  # just copy them from scale to trained guide
  copy_interactive_attrs(scale, zz)
}

#' @export
#' @importFrom purrr compact
guide_gengrob.interactive_colourbar <- function(guide, theme) {
  guide_gtable <- NextMethod()
  data <- compact(guide[IPAR_NAMES])
  # set them to the bar
  barIndex <- which(guide_gtable$layout$name == "bar")
  guide_gtable$grobs[[barIndex]] <-
    add_interactive_attrs(guide_gtable$grobs[[barIndex]],
                          data,
                          data_attr = "key-id")

  # or set them everywhere?
  # guide_gtable$grobs <- lapply(guide_gtable$grobs, function(z) {
  #   # some grobs may already be set interactive, from theme elements
  #   add_interactive_attrs(z, data, data_attr = "key-id", overwrite = FALSE)
  # })
  guide_gtable
}
