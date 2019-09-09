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

#' @export
guide_gengrob.interactive_guide <- function(guide, theme) {
  # make title interactive
  if (is.null(guide$title.theme))
    guide$title.theme <- calc_element("legend.title", theme)
  guide$title.theme = as_interactive_element_text(guide$title.theme)
  attr(guide$title.theme, "data_attr") <- "key-id"
  # make labels interactive
  if (is.null(guide$label.theme))
    guide$label.theme <- calc_element("legend.text", theme)
  guide$label.theme = as_interactive_element_text(guide$label.theme)
  attr(guide$label.theme, "data_attr") <- "key-id"

  NextMethod()
}
