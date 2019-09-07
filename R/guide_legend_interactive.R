#' @title Create interactive legend guide
#' @description
#' The guide is based on \code{\link[ggplot2]{guide_legend}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for guide_*_interactive functions
#' @seealso \code{\link{interactive_parameters}}
#' @seealso \code{\link{girafe}}
#' @export
guide_legend_interactive <- function(...)
  guide_interactive(guide_legend, "interactive_legend", ...)

#' @export
guide_train.interactive_legend <- function(guide,
                                           scale,
                                           aesthetic = NULL) {
  zz <- NextMethod()
  if (is.null(zz))
    return(zz)

  key <- zz$key
  breaks <- scale$get_breaks()
  rows = NULL
  if (length(breaks) > 0) {
    rows = breaks
  }
  key <- copy_interactive_attrs(scale, key, rows = rows)
  zz$key <- key
  zz
}
