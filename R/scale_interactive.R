#' Calls a base scale function and returns an interactive scale.
#' @noRd
scale_interactive <- function(scale_func,
                              ...,
                              ipar = IPAR_NAMES) {
  args <- list(...)
  # We need to get the interactive parameters from the arguments and remove them
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
    } else if (sc$guide %in% c("legend_interactive",
                               "bins_interactive",
                               "colourbar_interactive",
                               "colorbar_interactive",
                               "coloursteps_interactive",
                               "colorsteps_interactive")) {
      # ok
    } else {
      # the name could be a guide set by guides() and it might be interactive, but also it might not.
      # should we display a warning here?
    }
  } else if (inherits(sc$guide, "guide_none")) {
    # exit
    return(sc)
  } else if (inherits(sc$guide, "interactive_guide")) {
    # ok
  } else if (inherits(sc$guide, "legend")) {
      class(sc$guide) <- c("interactive_legend", "interactive_guide", class(sc$guide))
  } else if (inherits(sc$guide, "bins")) {
    class(sc$guide) <- c("interactive_bins", "interactive_guide", class(sc$guide))
  } else if (inherits(sc$guide, "colourbar") || inherits(sc$guide, "colorbar")) {
      class(sc$guide) <- c("interactive_colourbar", "interactive_guide", class(sc$guide))
  } else if (inherits(sc$guide, "coloursteps") || inherits(sc$guide, "colorsteps")) {
    class(sc$guide) <- c("interactive_coloursteps", "interactive_guide", class(sc$guide))
  } else {
    warning("Only `legend`, 'bins', `colourbar` and `coloursteps` guides are supported for interactivity")
    return(sc)
  }
  # Put back the interactive_params
  copy_interactive_attrs(interactive_params,
                         sc,
                         preserveNames = TRUE,
                         ipar = ipar)
}
