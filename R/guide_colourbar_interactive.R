#' @export
#' @title interactive colourbar guide
#' @description an interactive legend guide.
#' See \code{\link[ggplot2]{guide_legend}} for more details.
#' @param ... arguments passed to guide_legend.
guide_colourbar_interactive <- function(...) {
  zz <- guide_colourbar(...)
  class(zz) <- c("colourbar_interactive", class(zz))
  zz
}

#' @export
guide_geom.colourbar_interactive <- function(guide, layers, default_mapping){
  default_mapping <- append_aes(default_mapping, IPAR_DEFAULTS)
  NextMethod()
}

#' @export
#' @inheritParams ggplot2::guide_train
#' @param scale,aesthetic other parameters used by guide_train
#' @title methods for interactive colourbar guide
#' @description These functions should not be used by the end users.
guide_train.colourbar_interactive <- function(guide, scale, aesthetic = NULL) {
  zz <- NextMethod()
  zz <- copy_interactive_attrs(scale, zz, forceChar = FALSE)
  zz
}

#' @export
#' @importFrom purrr compact
guide_gengrob.colourbar_interactive <- function(guide, theme) {
  zz <- NextMethod()
  data <- compact(guide[IPAR_NAMES])
  zz$grobs <- lapply(zz$grobs,
         function(z){
           add_interactive_attrs(z, data, data_attr = "key-id")
         })
  zz
}
