#' @title Interactive parameters
#'
#' @description
#' Throughout ggiraph there are functions that add interactivity to ggplot plot elements.
#' The user can control the various aspects of interactivity by supplying
#' a special set of parameters to these functions.
#'
#' @param tooltip Tooltip text to associate with one or more elements.
#' If this is supplied a tooltip is shown when the element is hovered.
#' Plain text or html is supported.
#'
#' To use html markup it is advised to use [htmltools::HTML()] function
#' in order to mark the text as html markup.
#' If the text is not marked as html and no opening/closing tags were detected,
#' then any existing newline characters (`\r\n`, `\r` and `\n`)
#' are replaced with the `<br/>` tag.
#'
#' @param onclick Javascript code to associate with one or more elements.
#' This code will be executed when the element is clicked.
#'
#' @param hover_css Individual css style associate with one or more elements.
#' This css style is applied when the element is hovered and overrides the default style,
#' set via [opts_hover()], [opts_hover_key()] or [opts_hover_theme()].
#' It can also be constructed with \code{\link{girafe_css}},
#' to give more control over the css for different element types (see [opts_hover()] note).
#'
#' @param selected_css Individual css style associate with one or more elements.
#' This css style is applied when the element is selected and overrides the default style,
#' set via [opts_selection()], [opts_selection_key()] or [opts_selection_theme()].
#' It can also be constructed with \code{\link{girafe_css}},
#' to give more control over the css for different element types (see [opts_selection()] note).
#'
#' @param data_id Identifier to associate with one or more elements.
#' This is mandatory parameter if hover and selection interactivity is desired.
#' Identifiers are available as reactive input values in Shiny applications.
#'
#' @param tooltip_fill Color to use for tooltip background when [opts_tooltip()] `use_fill` is TRUE.
#' Useful for setting the tooltip background color in [geom_text_interactive()] or
#' [geom_label_interactive()], when the geom text color may be the same as the tooltip text color.
#'
#' @section Details for geom_*_interactive functions:
#' The interactive parameters can be supplied with two ways:
#' \itemize{
#'   \item As aesthetics with the mapping argument (via [aes()]).
#'   In this way they can be mapped to data columns and apply to a set of geometries.
#'
#'   \item As plain arguments into the geom_*_interactive function.
#'   In this way they can be set to a scalar value.
#' }
#'
#' @section Details for annotate_*_interactive functions:
#' The interactive parameters can be supplied as arguments in the relevant function
#' and they can be scalar values or vectors depending on params on base function.
#'
#' @section Details for scale_*_interactive and guide_*_interactive functions:
#' For scales, the interactive parameters can be supplied as arguments in the relevant function
#' and they can be scalar values or vectors, depending on the number of breaks (levels) and
#' the type of the guide used.
#' The guides do not accept any interactive parameter directly, they receive them from the scales.
#'
#' \itemize{
#'   \item When guide of type `legend` or `bins` is used, it will be converted to a
#'   [guide_legend_interactive()] or [guide_bins_interactive()] respectively,
#'   if it's not already.
#'
#'   The length of each scale interactive parameter vector should match the length of the breaks.
#'   It can also be a named vector, where each name should correspond to the same break name.
#'   It can also be defined as function that takes the breaks as input and returns a named or
#'   unnamed vector of values as output.
#'
#'   The interactive parameters here, give interactivity only to the key elements of the guide.
#'
#'   \item When guide of type `colourbar` or `coloursteps` is used, it will be converted to a
#'   [guide_colourbar_interactive()] or [guide_coloursteps_interactive()]
#'   respectively, if it's not already.
#'
#'   The scale interactive parameters in this case should be scalar values and give interactivity
#'   to the colorbar only.
#' }
#'
#' To provide interactivity to the rest of the elements of a guide, (title, labels, background, etc),
#' the relevant theme elements or relevant guide arguments can be used.
#' The \code{guide} arguments `title.theme` and `label.theme` can be defined as
#' \code{element_text_interactive} (in fact, they will be converted to that if they are not
#' already), either directly or via the theme.
#' See the element_*_interactive section for more details.
#'
#' @section Details for element_*_interactive functions:
#' The interactive parameters can be supplied as arguments in the relevant function
#' and they should be scalar values.
#'
#' For theme text elements ([element_text_interactive()]), the interactive parameters
#' can also be supplied while setting a label value, via the [labs()] family
#' of functions or when setting a scale/guide title or key label.
#' Instead of setting a character value for the element, function
#' [label_interactive()] can be used to define interactive parameters
#' to go along with the label.
#' When the parameters are supplied that way, they override the default values
#' that are set at the theme via [element_text_interactive()] or via the \code{guide}'s
#' theme parameters.
#'
#' @section Details for interactive_*_grob functions:
#' The interactive parameters can be supplied as arguments in the relevant function
#' and they can be scalar values or vectors depending on params on base function.
#'
#' @section Custom interactive parameters:
#' The argument `extra_interactive_params` can be passed to any of the *_interactive functions
#' (geoms, grobs, scales, labeller, labels and theme elements),
#' It should be a character vector of additional names to be treated as interactive parameters
#' when evaluating the aesthetics.
#' The values will eventually end up as attributes in the SVG elements of the output.
#'
#' Intended only for expert use.
#'
#' @seealso [girafe_options()], [girafe()]
#' @rdname ipar
#' @name interactive_parameters
NULL

# A list of interactive parameters.
# Important: data_id should always be first,
# so that it's the first attribute that is set in the svg element.
IPAR_DEFAULTS <- list(
  data_id = NULL,
  tooltip = NULL,
  onclick = NULL,
  hover_css = NULL,
  selected_css = NULL,
  tooltip_fill = NULL
)

IPAR_NAMES <- names(IPAR_DEFAULTS)

#' Checks if passed object contains interactive parameters.
#' @noRd
has_interactive_attrs <- function(x, ipar = IPAR_NAMES) {
  length(intersect(names(x), ipar)) > 0
}

#' Returns the names of the interactive parameters that may exist in an object.
#' @noRd
get_interactive_attr_names <- function(x, ipar = IPAR_NAMES) {
  intersect(names(x), ipar)
}

#' Returns the active names of the interactive parameters,
#' combining the default names with any extra names.
#' @noRd
get_default_ipar <- function(extra_names = NULL) {
  if (is.character(extra_names) && length(extra_names) > 0) {
    extra_names <- Filter(x = extra_names, function(x) {
      !is.na(x) && nzchar(trimws(x))
    })
  }
  unique(c(IPAR_NAMES, extra_names))
}

#' Returns the interactive parameters that may exist in an object
#' or in the parent environment by default,
#' or inside an "interactive" attribute of the object.
#' @noRd
#' @importFrom rlang env_get_list caller_env
get_interactive_attrs <- function(x = caller_env(), ipar = IPAR_NAMES) {
  if (is.environment(x)) {
    env_get_list(env = x, ipar, NULL)
  } else {
    if (!is.null(attr(x, "interactive"))) {
      x <- attr(x, "interactive")
    }
    x[get_interactive_attr_names(x, ipar = ipar)]
  }
}

#' Removes the interactive parameters from an object.
#' @noRd
remove_interactive_attrs <- function(x, ipar = IPAR_NAMES) {
  for (a in ipar) {
    x[[a]] <- NULL
  }
  x
}

#' Copies interactive parameters from one object to the other.
#' and returns the result
#' @noRd
copy_interactive_attrs <- function(src,
                                   dest,
                                   ...,
                                   useList = FALSE,
                                   rows = NULL,
                                   ipar = IPAR_NAMES) {
  hasDots <- length(list(...)) > 0
  for (a in ipar) {
    if (!is.null(src[[a]])) {
      if (length(rows) == 0 || length(src[[a]]) == 1) {
        val <- src[[a]]
      } else {
        val <- src[[a]][rows]
      }
      if (is.function(val)) {
        dest[[a]] <- val
      } else if (hasDots && useList) {
        dest[[a]] <- unlist(mapply(rep, val, ...))
      } else if (hasDots) {
        dest[[a]] <- rep(val, ...)
      } else {
        dest[[a]] <- val
      }
    }
  }
  dest
}

#' Add the interactive parameters from a data object to a grob.
#' and changes its class
#' @noRd
add_interactive_attrs <- function(gr,
                                  data,
                                  rows = NULL,
                                  cl = NULL,
                                  overwrite = TRUE,
                                  data_attr = "data-id",
                                  ipar = IPAR_NAMES) {
  # check for presence of interactive parameters
  anames <- Filter(x = get_interactive_attr_names(data, ipar = ipar), function(a) {
    !is.null(data[[a]])
  })
  if (length(anames) == 0)
    return(gr)

  # if passed grob is a gTree, loop through the children
  # note that some grobs (like labelgrob) inherit from gTree,
  # but have no children. So we need to check the children length, first.
  if (inherits(gr, "gTree") && length(gr$children) > 0) {
    # check the lengths of children grobs and data
    data_len <- nrow(data)
    children_len <- length(gr$children)
    if (is.null(data_len) || data_len == 1) {
      # pass the data as a whole
      for (i in seq_along(gr$children)) {
        gr$children[[i]] <-
          do_add_interactive_attrs(
            gr = gr$children[[i]],
            data = data,
            rows = rows,
            cl = cl,
            overwrite = overwrite,
            data_attr = data_attr,
            ipar = anames
          )
      }

    } else if (children_len == data_len) {
      # pass the correct data row
      for (i in seq_along(gr$children)) {
        gr$children[[i]] <-
          do_add_interactive_attrs(
            gr = gr$children[[i]],
            data = data[i, , drop = FALSE],
            rows = rows,
            cl = cl,
            overwrite = overwrite,
            data_attr = data_attr,
            ipar = anames
          )
      }
    } else {
      stop("Can't add interactive attrs to gTree", call. = FALSE)
    }
    return(gr)

  } else {
    do_add_interactive_attrs(
      gr = gr,
      data = data,
      rows = rows,
      cl = cl,
      overwrite = overwrite,
      data_attr = data_attr,
      ipar = anames
    )
  }
}

#' Delegate for add_interactive_attrs
#' @noRd
do_add_interactive_attrs <- function(gr,
                                     data,
                                     rows = NULL,
                                     cl = NULL,
                                     overwrite = TRUE,
                                     data_attr = "data-id",
                                     ipar = IPAR_NAMES) {

  # check that is a grob
  if (!is.grob(gr) || is.zero(gr))
    return(gr)
  # check if it's interactive grob already
  isInteractive <- length(grep("interactive_", class(gr))) > 0
  ip <- get_interactive_data(gr)
  if (length(rows) == 0) {
    for (a in ipar) {
      if (!isInteractive || isTRUE(overwrite) || is.null(ip[[a]]))
        ip[[a]] <- data[[a]]
    }
  } else {
    for (a in ipar) {
      if (!isInteractive || isTRUE(overwrite) || is.null(ip[[a]]))
        ip[[a]] <- data[[a]][rows]
    }
  }
  gr$.ipar <- ipar
  gr$.interactive <- ip
  gr$.data_attr <- data_attr

  if (is.null(cl) && !isInteractive) {
    cl <- paste("interactive", class(gr)[1], "grob", sep = "_")
    # some grobs have class name which contains "grob" already, like rastergrob
    # and labelgrob, so they end up named like interactive_rastergrob_grob.
    # we normalize the name here, to use class interactive_raster_grob.
    cl <- sub("grob_grob", "_grob", cl, ignore.case = TRUE)
  }
  # just extend the class, so that it inherits other grob methods
  class(gr) <- c(cl, class(gr))
  gr
}

get_interactive_data <- function(x, default = list()) {
  (if(!is.atomic(x)) x$.interactive) %||% attr(x, "interactive") %||% default
}

get_ipar <- function(x, default = IPAR_NAMES) {
  ipar <- (if(!is.atomic(x)) x$.ipar) %||% attr(x, "ipar")
  if (length(ipar) > 0 && is.character(ipar)) {
    ipar
  } else {
    default
  }
}

get_data_attr <- function(x, default = "data-id") {
  data_attr <- (if(!is.atomic(x)) x$.data_attr) %||% attr(x, "data_attr")
  if (length(data_attr) == 1 && is.character(data_attr)) {
    data_attr
  } else {
    default
  }
}

#' Sets the interactive attributtes to the svg output.
#' @noRd
interactive_attr_toxml <- function(x,
                                   ids = character(0),
                                   rows = NULL) {
  if (length(ids) < 1)
    return(invisible())

  ip <- get_interactive_data(x)
  ipar <- get_ipar(x)
  data_attr <- get_data_attr(x)
  # check for presence of interactive parameters
  anames <- Filter(x = get_interactive_attr_names(ip, ipar = ipar), function(a) {
    !is.null(ip[[a]])
  })
  if (length(anames) == 0)
    return(invisible())

  for (a in anames) {
    if (length(rows) == 0) {
      attrValue <- ip[[a]]
    } else {
      attrValue <- ip[[a]][rows]
    }
    attrValue <- switch(a,
                        tooltip = encode_cr(attrValue),
                        hover_css = check_css_attr(attrValue),
                        selected_css = check_css_attr(attrValue),
                        attrValue)
    if (!is.character(attrValue))
      attrValue <- as.character(attrValue)
    attrName <- switch(a,
                       tooltip = "title",
                       data_id = data_attr,
                       a)
    set_attr(ids = as.integer(ids),
             str = attrValue,
             attribute = attrName)
  }
  invisible()
}
