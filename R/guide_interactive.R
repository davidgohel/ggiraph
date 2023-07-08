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
  ipar <- get_ipar(guide)
  # set the defaults for any extra parameter
  default_aes_names <- names(default_mapping)
  missing_names <- setdiff(ipar, default_aes_names)
  if (length(missing_names) > 0) {
    defaults <- Map(missing_names, f=function(x) NULL)
    default_mapping <- append_aes(default_mapping, defaults)
  }
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
copy_interactive_attrs_from_scale <- function(guide, scale, ipar = get_ipar(scale)) {
  key <- guide$key
  breaks <- scale$get_breaks()

  key_ipar = c()

  # copy attributes from scale to key
  if (length(breaks) > 0) {
    # process the interactive params one by one and check for names
    # this way it works for both discrete and continuous scales
    # with or without named vectors
    for (a in ipar) {
      if (!is.null(scale[[a]])) {
        key_ipar <- c(key_ipar, a)
        # check if it's function
        if (is.function(scale[[a]])) {
          scale[[a]] <- do.call(scale[[a]], list(breaks))
        }
        # check if it's named vector
        if (!is.null(names(scale[[a]]))) {
          # If parameter have names, use them to match with breaks
          values <- breaks
          m <- match(names(scale[[a]]), values, nomatch = 0)
          values[m] <- scale[[a]][m != 0]
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
    ipar = key_ipar
    # handle labels
    # continuous scales break the label_interactive struct
    if (!scale$is_discrete()) {
      labels <- scale$get_labels(breaks)
      if (inherits(labels, "interactive_label")) {
        lbl_ipar <- get_ipar(labels)
        lbl_ip <- transpose(get_interactive_data(labels))
        extra_interactive_params <- setdiff(lbl_ipar, IPAR_NAMES)

        # get the rows of valid labels
        limits <- scale$get_limits()
        noob <- !is.na(breaks) & limits[1] <= breaks & breaks <= limits[2]

        # create a list of individual labels
        labels <- lapply(which(noob), function(i) {
          args <- c(list(
            label = labels[[i]],
            extra_interactive_params = extra_interactive_params
          ), lbl_ip[[i]])
          do.call(label_interactive, args)
        })
        if (guide$reverse) {
          labels <- rev(labels)
        }
        key$.label <- labels
      }
    }

  } else {
    key <- copy_interactive_attrs(scale, key, ipar = ipar)
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
  guide$.ipar <- ipar
  guide
}

# checks that all key ipar is in guide$geoms data
check_guide_key_geoms <- function(guide) {
  if (!is.null(guide)) {
    ipar = get_ipar(guide)
    guide$geoms <- lapply(guide$geoms, function(g) {
      missing_names <- setdiff(ipar, names(g$data))
      missing_names <- intersect(missing_names, names(guide$key))
      if (length(missing_names)) {
        for (name in missing_names) {
          g$data[[name]] <- guide$key[[name]]
        }
      }
      g
    })
  }

  guide
}

ggproto_guide_interactive <- function(guide) {
  force(guide)
  ggproto(
    "GuideInteractive", guide,
    override_elements = function(params, elements, theme) {
      elements <- guide$override_elements(params, elements, theme)
      elements$title <- as_interactive_element_text(elements$title)
      attr(elements$title, "data_attr") <- "key-id"
      elements$text <- as_interactive_element_text(elements$text)
      attr(elements$text, "data_attr") <- "key-id"
      elements
    }
  )
}
