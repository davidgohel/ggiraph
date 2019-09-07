#' Calls a base guide function and returns an interactive guide.
#' @noRd
guide_interactive <- function(guide_func,
                              cl,
                              ...) {
  args <- list(...)
  # Call default guide function
  guide <- do.call(guide_func, args)
  class(guide) <- c(cl, "interactive_guide", class(guide))
  guide
}

#' @export
guide_geom.interactive_guide <- function(guide,
                                         layers,
                                         default_mapping) {
  default_mapping <- append_aes(default_mapping, IPAR_DEFAULTS)
  NextMethod()
}
