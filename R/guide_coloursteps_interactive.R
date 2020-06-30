#' @title Create interactive colorsteps guide
#' @description
#' The guide is based on [guide_coloursteps()].
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @examples
#' # add interactive coloursteps guide to a ggplot -------
#' @example examples/scale_viridis_guide_coloursteps_interactive.R
#' @seealso [interactive_parameters()], [girafe()]
#' @export
guide_coloursteps_interactive <- function(...)
  guide_interactive(guide_coloursteps, "interactive_coloursteps", ...)

#' @export
#' @rdname guide_coloursteps_interactive
guide_colorsteps_interactive <- guide_coloursteps_interactive

#' @export
#' @importFrom purrr imap
guide_train.interactive_coloursteps <- function(guide,
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
guide_gengrob.interactive_coloursteps <- function(guide, theme) {
  guide_gtable <- NextMethod()
  data <- compact(guide[IPAR_NAMES])
  # set them to the bar
  barIndex <- which(guide_gtable$layout$name == "bar")
  guide_gtable$grobs[[barIndex]] <-
    add_interactive_attrs(guide_gtable$grobs[[barIndex]],
                          data,
                          data_attr = "key-id")

  guide_gtable
}
