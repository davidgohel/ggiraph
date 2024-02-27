#' Calls a base scale function and returns an interactive scale.
#' @noRd
#' @importFrom rlang inherits_any list2
scale_interactive <- function(scale_func,
                              ...,
                              extra_interactive_params = NULL) {
  args <- list2(...)
  # We need to get the interactive parameters from the arguments and remove them
  ipar <- get_default_ipar(extra_interactive_params)
  interactive_params <- get_interactive_attrs(args, ipar = ipar)
  args <- remove_interactive_attrs(args, ipar = ipar)
  # Call default scale function
  sc <- do.call(scale_func, args)
  # set the guide
  if (isFALSE(sc$guide) || is.null(sc$guide)) {
    # no guide
    return(sc)
  } else if (is.character(sc$guide)) {
    if (sc$guide %in% c("none", "guide_none")) {
      # exit
      return(sc)
    } else if (sc$guide %in% c("legend", "bins", "colourbar", "colorbar", "coloursteps", "colorsteps")) {
      sc$guide <- paste0(sc$guide, "_interactive")
    } else if (sc$guide %in% c(
      "legend_interactive",
      "bins_interactive",
      "colourbar_interactive",
      "colorbar_interactive",
      "coloursteps_interactive",
      "colorsteps_interactive"
    )) {
      # ok
    } else {
      # the name could be a guide set by guides() and it might be interactive, but also it might not.
      # should we display a warning here?
    }
  } else if (inherits(sc$guide, "guide_none")) {
    # exit
    return(sc)
  } else if (inherits_any(sc$guide, c(
    "GuideInteractiveLegend", "GuideInteractiveBins", "GuideInteractiveColourbar", "GuideInteractiveColoursteps"
  ))
  ) {
    # ok
  } else if (inherits_any(sc$guide, c(
    "GuideLegend", "GuideBins", "GuideColourbar", "GuideColoursteps"
  ))
  ) {
    interactive_guide <- NULL
    if (inherits(sc$guide, "GuideColourbar")) {
      # we must resolve if it's GuideColourbar or GuideColoursteps
      if (!is.null(sc$guide$params$even.steps)) {
        interactive_guide <- GuideInteractiveColoursteps
      }
    }
    sc$guide <- guide_interactive(sc$guide, interactive_guide = interactive_guide)
  } else {
    warning("Only `legend`, 'bins', `colourbar` and `coloursteps` guides are supported for interactivity")
    return(sc)
  }
  # Put back the interactive_params
  sc <- copy_interactive_attrs(interactive_params, sc, ipar = ipar)
  sc$.ipar <- ipar
  sc
}
