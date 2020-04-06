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

#' Used in guide_legend/guide_bins to copy the interactive attributes to guide keys
#' @noRd
copy_interactive_attrs_from_scale <- function(guide, scale) {

  key <- guide$key
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
  guide$key <- key
  guide
}

