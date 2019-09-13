#' @title Create interactive legend guide
#' @description
#' The guide is based on \code{\link[ggplot2]{guide_legend}}.
#' See the documentation for that function for more details.
#'
#' @param ... arguments passed to base function.
#' @return An interactive guide object.
#' @inheritSection interactive_parameters Details for scale_*_interactive and guide_*_interactive functions
#' @examples
#' # add interactive discrete legend guide to a ggplot -------
#' @example examples/scale_manual_guide_legend_discrete_interactive.R
#' @examples
#' # add interactive continuous legend guide to a ggplot -------
#' @example examples/scale_viridis_guide_legend_continuous_interactive.R
#' @seealso \code{\link{interactive_parameters}}
#' @seealso \code{\link{girafe}}
#' @export
guide_legend_interactive <- function(...)
  guide_interactive(guide_legend, "interactive_legend", ...)

#' @export
#' @importFrom purrr imap
guide_train.interactive_legend <- function(guide,
                                           scale,
                                           aesthetic = NULL) {
  zz <- NextMethod()
  if (is.null(zz))
    return(zz)

  key <- zz$key
  breaks <- scale$get_breaks()

  # copy attributes from scale to key
  if (length(breaks) > 0) {
    # process the interactive params one by one and check for names
    # this way it works for both discrete and continuous scales
    # with or without named vectors
    for (a in IPAR_NAMES) {
      if (!is.null(scale[[a]])) {
        # check if it's function
        if (is.function(scale[[a]])) {
          scale[[a]] <- do.call(scale[[a]], list(breaks))
        }
        # check if it's named vector
        if (!is.null(names(scale[[a]]))) {
          # If parameter have names, use them to match with breaks
          values <- breaks
          m <- match(names(scale[[a]]), values, nomatch = 0)
          values[m] <- as.character(scale[[a]][m != 0])
          key[[a]] <- values
        } else {
          values <- as.character(scale[[a]])
          # Need to ensure that if breaks were dropped, corresponding values are too
          pos <- attr(breaks, "pos")
          if (!is.null(pos)) {
            values <- values[pos]
          } else if (!scale$is_discrete()) {
            #drop NAs
            values <- values[!is.na(values)]
          }
          key[[a]] <- values
        }
      }
    }
  } else {
    key <- copy_interactive_attrs(scale, key)
  }
  # copy attributes from key to labels
  # disabled for the moment, until css issue is resolved
  # key$.label <- imap(key$.label, function(label, i) {
  #   key_ip <- copy_interactive_attrs(key, list(), rows = i)
  #   if (!inherits(label, "interactive_label")) {
  #     args <- c(label = label, key_ip)
  #     label = do.call(label_interactive, args)
  #   } else {
  #     label_ip = get_interactive_attrs(label)
  #     label_ip <- modify_list(label_ip, key_ip)
  #     attr(label, "interactive") <- label_ip
  #   }
  #   label
  # })
  zz$key <- key
  zz
}
