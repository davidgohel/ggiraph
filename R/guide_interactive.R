#' Calls a base guide function and returns an interactive guide.
#' @noRd
guide_interactive <- function(guide_func,
                              ...,
                              interactive_guide = NULL) {
  args <- list(...)
  # Call default guide function
  if (is.function(guide_func)) {
    guide <- do.call(guide_func, args)
  } else if (inherits(guide_func, "Guide")) {
    guide <- guide_func
  } else {
    abort("Invalid guide_func argument!")
  }
  if (is.null(interactive_guide)) {
    interactive_guide <- find_interactive_class(guide, baseclass = "Guide")
  }

  ggproto(
    NULL, interactive_guide,
    params = guide$params,
    elements = guide$elements,
    available_aes = guide$available_aes
  )
}

#' train interactive guide
#' @details
#' Copies the interactive parameters and labels from the scale to the guide.
#' Used in all interactive guides.
#' @param params trained guide params, the result of guide's train method
#' @param scale the guide's scale
#' @param breaks the breaks for guide keys/decor
#' @param label_breaks the breaks for the labels
#' @param max_len the max length of each interactive parameter vector
#' @return the altered guide params
#' @noRd
interactive_guide_train <- function(params, scale, breaks,
                                    label_breaks = breaks,
                                    max_len = NULL) {
  if (!is.null(params)) {
    key <- params$key
    if (is.data.frame(key) && nrow(key)) {
      # copy interactive attributes from scale
      ipar <- get_ipar(scale)
      idata <- list()
      # process the interactive params one by one and check for names
      # this way it works for both discrete and continuous scales
      # with or without named vectors
      for (a in ipar) {
        if (is.function(scale[[a]])) {
          scale[[a]] <- do.call(scale[[a]], list(breaks))
        }
        if (length(scale[[a]])) {
          # check if it's named vector
          if (!is.null(names(scale[[a]]))) {
            # If parameter have names, use them to match with breaks
            values <- breaks
            m <- match(names(scale[[a]]), values, nomatch = 0)
            values[m] <- scale[[a]][m != 0]
          } else {
            values <- as.character(scale[[a]])
          }
          # length of values should be 1 or same as breaks
          if (length(values) > 1 && length(values) != length(breaks)) {
            warning(paste0(
              "Cannot set the guide interactive attribute '", a,
              "', because its length differs from the breaks length"
            ))
          } else {
            # length of values must match provided max length or
            # the rows of decor data frame or the rows of key data frame
            max_len <- max_len %||% nrow(params$decor) %||% nrow(params$key) %||% 0
            if (max_len > 0 && length(values) > max_len) {
              values <- values[seq_len(max_len)]
            }
            # special case for coloursteps guide, when the lengths may not match
            if (!is.null(params$decor) && length(values) > 1 &&
              nrow(params$decor) > length(values)
            ) {
              # sort the breaks
              sorted_breaks <- sort(breaks)
              # find the bin index of the decor values
              decor2break <- findInterval(params$decor$value, sorted_breaks,
                rightmost.closed = TRUE, all.inside = TRUE
              )
              if (!identical(breaks, sorted_breaks)) {
                # map from sorted breaks to original breaks
                m <- match(breaks, sorted_breaks[seq_len(max_len)], nomatch = 0)
                m <- m[m != 0]
                # remap the bin indices
                decor2break <- sapply(decor2break, function(i) m[i])
              }
              # spread the values accordingly
              values <- sapply(decor2break, function(i) values[i])
            }
            idata[[a]] <- values
          }
        }
      }
      params$.ipar <- ipar
      params$.interactive <- idata

      # continuous scales might break the label_interactive struct
      # and we need to replace the labels
      if (is.numeric(label_breaks)) {
        labels <- scale$get_labels(label_breaks)
        if (inherits(labels, "interactive_label")) {
          if (length(labels) != nrow(key)) {
            warning(paste0(
              "Cannot set the guide interactive labels, ",
              "', because its length differs from the breaks length"
            ))
          } else {
            key$.label <- labels
            params$key <- key
          }
        }
      }
    }
  }
  params
}

parse_binned_breaks <- ggplot2:::parse_binned_breaks

#' Parse binned breaks of interactive guide
#' @details
#' Enhanced version of ggplot's parse_binned_breaks.
#' Provides all key breaks (breaks + limits) plus the original scale breaks.
#' Used in binned guides (bins and colorsteps).
#' @param scale the guide's scale
#' @param params the guide's parameters
#' @return A list
#' @noRd
interactive_guide_parse_binned_breaks <- function(scale, params) {
  scale_breaks <- scale$get_breaks()
  even.steps <- params$even.steps %||% TRUE
  parsed <- parse_binned_breaks(scale, scale_breaks, even.steps)
  parsed$scale_breaks <- scale_breaks
  if (is.character(scale$labels) || is.numeric(scale$labels)) {
    limit_breaks <- c(NA, NA)
  } else {
    limit_breaks <- parsed$limits
  }
  all_breaks <- parsed$breaks
  if (!parsed$breaks[1] %in% parsed$limits) {
    all_breaks <- c(limit_breaks[1], all_breaks)
  }
  if (!parsed$breaks[length(parsed$breaks)] %in% parsed$limits) {
    all_breaks <- c(all_breaks, limit_breaks[2])
  }
  if (params$reverse) {
    all_breaks <- rev(all_breaks)
  }
  parsed$all_breaks <- all_breaks
  parsed
}

#' Override elements in interactive guide
#' @details
#' Converts the theme elements of the guide to interactive theme elements.
#' Used in all interactive guides.
#'
#' @param elements The guide's elements, the result of guide's override_elements method
#' @return the altered guide elements
#' @noRd
interactive_guide_override_elements <- function(elements) {
  # make title interactive
  if (inherits(elements$title, "element_text") && !inherits(elements$title, "interactive_element_text")) {
    elements$title <- as_interactive_element_text(elements$title)
    attr(elements$title, "data_attr") <- "key-id"
  }
  # make labels interactive
  if (inherits(elements$text, "element_text") && !inherits(elements$text, "interactive_element_text")) {
    elements$text <- as_interactive_element_text(elements$text)
    attr(elements$text, "data_attr") <- "key-id"
  }
  elements
}

#' build_decor method
#' @details
#' Copies the interactive parameters from the guide to the decor data,
#' before the geoms build the legend keys.
#' Used in guides legend and bins.
#'
#' @param decor the guide's decor structure
#' @param params the guide's parameters
#'
#' @return the altered guide's decor structure
#' @noRd
interactive_guide_build_decor <- function(decor, params) {
  # copy missing interactive columns to decor
  idata <- get_interactive_data(params)
  if (length(idata) && length(decor)) {
    decor <- lapply(decor, function(g) {
      missing_names <- setdiff(names(idata), names(g$data))
      if (length(missing_names)) {
        for (name in missing_names) {
          g$data[[name]] <- idata[[name]]
        }
      }
      g
    })
  }
  decor
}
