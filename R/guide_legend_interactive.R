#' @title Create interactive legend guide
#' @description
#' The guide is based on [guide_legend()].
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
guide_legend_interactive <- function(...)
  guide_interactive(guide_legend, "interactive_legend", ...)

ggproto_legend_interactive <- function(guide) {
  force(guide)
  ggproto(
    NULL, guide,
    train = function(params, scale, aesthetic = NULL, ...) {
      out <- guide$train(params, scale, aesthetic, ...)
      if (!is.null(out)) {
        out <- copy_interactive_attrs_from_scale(out, scale)
      }
      out
    },
    get_layer_key = function(params, layers) {
      out <- guide$get_layer_key(params, layers)
      out <- check_guide_key_geoms(out, "decor")
      out
    }
  )
}

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

#' @export
guide_geom.interactive_legend <- function(guide,
                                         layers,
                                         default_mapping) {
  check_guide_key_geoms(NextMethod())
}
