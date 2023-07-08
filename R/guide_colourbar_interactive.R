#' @title Create interactive continuous colour bar guide
#' @description
#' The guide is based on [guide_colourbar()].
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
guide_colourbar_interactive <- function(..., .guide = NULL) {
  guide <- guide_interactive(guide_colourbar, "interactive_colourbar", ...)
  if (!inherits(guide, "Guide")) {
    return(guide)
  } else {
    ggproto_colourbar_interactive(guide)
  }
}

ggproto_colourbar_interactive <- function(guide) {
  force(guide)
  ggproto(
    NULL, guide,
    train = function(params, scale, aesthetic = NULL, ...) {
      out <- guide$train(params, scale, aesthetic, ...)
      if (!is.null(out)) {
        out$.ipar <- ipar <- get_ipar(scale)
        out$.interactive <- copy_interactive_attrs(scale, list(), ipar = ipar)
      }
      out
    },
    draw = function(theme, params) {
      gtable <- guide$draw(theme, params)
      ipar <- get_ipar(params)
      data <- get_interactive_data(params)
      # set them to the bar
      barIndex <- which(gtable$layout$name == "bar")
      gtable$grobs[[barIndex]] <-
        add_interactive_attrs(gtable$grobs[[barIndex]],
                              data,
                              data_attr = "key-id",
                              ipar = ipar)
      gtable
    }
  )
}

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
  ipar = get_ipar(scale)
  data <- copy_interactive_attrs(scale, list(), ipar = ipar)
  zz$.interactive <- data
  zz$.ipar <- ipar
  zz
}

#' @export
#' @importFrom purrr compact
guide_gengrob.interactive_colourbar <- function(guide, theme) {
  guide_gtable <- NextMethod()
  ipar <- get_ipar(guide)
  data <- get_interactive_data(guide)
  # set them to the bar
  barIndex <- which(guide_gtable$layout$name == "bar")
  guide_gtable$grobs[[barIndex]] <-
    add_interactive_attrs(guide_gtable$grobs[[barIndex]],
                          data,
                          data_attr = "key-id",
                          ipar = ipar)

  # or set them everywhere?
  # guide_gtable$grobs <- lapply(guide_gtable$grobs, function(z) {
  #   # some grobs may already be set interactive, from theme elements
  #   add_interactive_attrs(z, data, data_attr = "key-id", overwrite = FALSE)
  # })
  guide_gtable
}
