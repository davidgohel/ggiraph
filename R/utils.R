# Include generic helpers from ggplot2
#' @include utils_ggplot2.R
#' @include utils_ggplot2_performance.R

# FIXME
# dapply is in ggplot2/compat-plyr.R, but if we include that file,
# it causes more issues as it depends ggplot2 globals.
# dapply is only used in GeomInteractivePath.
dapply <- ggplot2:::dapply


#' Encodes the attribute value designated for tooltip
#' @importFrom htmltools htmlEscape
#' @noRd
encode_cr <- function(x)
  htmltools::htmlEscape(text = gsub(
    pattern = "\n",
    replacement = "<br>",
    x = x
  ),
  attribute = TRUE)


#' @section Geoms:
#'
#' All `geom_*_interactive` functions (like `geom_point_interactive`) return a layer that
#' contains a `GeomInteractive*` object (like `GeomInteractivePoint`). The `Geom*`
#' object is responsible for rendering the data in the plot.
#'
#' See \code{\link[ggplot2]{Geom}} for more information.
#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @title ggproto classes for ggiraph
#' @name GeomInteractive
NULL

INTERACTIVE_ATTR_NAMES <- c("tooltip", "onclick", "data_id")
INTERACTIVE_ATTR_DEFAULTS <- list(tooltip = NULL,
                                  onclick = NULL,
                                  data_id = NULL)

#' Ensures that interactive attributes are characters.
#' @noRd
force_interactive_aes_to_char <- function(data) {
  for (a in INTERACTIVE_ATTR_NAMES) {
    if (!is.null(data[[a]]) && !is.character(data[[a]])) {
      data[[a]] <- as.character(data[[a]])
    }
  }
  data
}

#' Copies interactive attributes from one object to the other.
#' and returns the result
#' @noRd
copy_interactive_attrs <-
  function(src, dest, forceChar = TRUE, useList = FALSE, rows = NULL, ...) {
    for (a in INTERACTIVE_ATTR_NAMES) {
      if (!is.null(src[[a]])) {
        if (is.null(rows)) {
          val <- src[[a]]
        } else {
          val <- src[[a]][rows]
        }
        if (forceChar)
          val <- as.character(val)
        if (useList) {
          dest[[a]] <- unlist(mapply(rep, val, ...))
        } else {
          dest[[a]] <- rep(val, ...)
        }
      }
    }
    dest
  }

#' Checks if passed object contains interactive attributes.
#' @noRd
has_interactive_attrs <- function(x) {
  for (a in INTERACTIVE_ATTR_NAMES) {
    if (!is.null(x[[a]]))
      return(TRUE)
  }
  FALSE
}

#' Returns the names of the interactive attributes that may exist in an object.
#' @noRd
get_interactive_attr_names <- function(x) {
  intersect(names(x), INTERACTIVE_ATTR_NAMES)
}

#' Returns the interactive attributes that may exist in an object
#' or in the parent environment by default.
#' @noRd
#' @importFrom rlang env_get_list caller_env
get_interactive_attrs <- function(x = caller_env()) {
  if (is.environment(x)) {
    env_get_list(env = x, INTERACTIVE_ATTR_NAMES)
  } else {
    x[get_interactive_attr_names(x)]
  }
}

#' Removes the interactive attributes from an object.
#' @noRd
remove_interactive_attrs <- function(x) {
  for (a in INTERACTIVE_ATTR_NAMES) {
    x[[a]] <- NULL
  }
  x
}

#' Add the interactive attributes from a data object to a grob.
#' and changes its class
#' @noRd
add_interactive_attrs <- function(gr,
                                  data,
                                  rows = NULL,
                                  cl = NULL,
                                  data_attr = "data-id") {
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
          add_interactive_attrs(
            gr = gr$children[[i]],
            data = data,
            cl = cl,
            data_attr = data_attr
          )
      }

    } else if (children_len == data_len) {
      # pass the correct data row
      for (i in seq_along(gr$children)) {
        gr$children[[i]] <-
          add_interactive_attrs(
            gr = gr$children[[i]],
            data = data[i, , drop = FALSE],
            cl = cl,
            data_attr = data_attr
          )
      }
    } else {
      stop("Can't add interactive attrs to gTree", call. = FALSE)
    }
    return(gr)
  }
  if (is.null(rows)) {
    for (a in INTERACTIVE_ATTR_NAMES) {
      gr[[a]] <- data[[a]]
    }
  } else {
    for (a in INTERACTIVE_ATTR_NAMES) {
      gr[[a]] <- data[[a]][rows]
    }
  }
  gr$data_attr <- data_attr

  if (is.null(cl)) {
    cl <- paste("interactive", class(gr)[1], "grob", sep = "_")
    # some grobs have class name which contains "grob" already, like rastergrob
    # and labelgrob, so they end up named like interactive_rastergrob_grob.
    # we normalize the name here, to use class interactive_raster_grob.
    cl <- sub("grob_grob", "_grob", cl)
  }
  class(gr)[1] <- cl
  gr
}

#' Generates a default aesthetics mapping for an interactive class
#' by copying the default aes and appending the interactive attrs.
#' @noRd
add_default_interactive_aes <- function(geom = Geom) {
  append_aes(geom$default_aes, INTERACTIVE_ATTR_DEFAULTS)
}

#' Appends a list of attributes to an aesthetic mapping.
#' @noRd
append_aes <- function(mapping, lst) {
  aes_new <- structure(lst, class = "uneval")
  mapping[names(aes_new)] <- aes_new
  mapping
}

#' Sets the interactive attributtes to the svg output.
#' @noRd
interactive_attr_toxml <- function(x,
                                   ids = character(0),
                                   rows = NULL,
                                   attr_name = "data-id") {
  if (length(ids) < 1)
    return(invisible())

  if (!is.null(x$data_attr)) {
    attr_name <- x$data_attr
  }
  if (is.null(rows)) {
    for (a in INTERACTIVE_ATTR_NAMES) {
      if (is.null(rows) && !is.null(x[[a]])) {
        rows <- seq_along(x[[a]])
      }
    }
  }

  for (a in INTERACTIVE_ATTR_NAMES) {
    if (!is.null(x[[a]])) {
      attrValue <- x[[a]][rows]
      attrValue <- switch(a,
                          tooltip = encode_cr(attrValue),
                          attrValue)
      attrName <- switch(a,
                         tooltip = "title",
                         data_id = attr_name,
                         a)
      set_attr(ids = as.integer(ids),
               str = attrValue,
               attribute = attrName)
    }
  }
  invisible()
}

#' Returns the arguments for a grob function
#' @noRd
grob_argnames <- function(x, grob) {
  intersect(names(formals(grob)), names(x))
}

#' Calls a base gggplot2 geom/layer function and replaces the geom param
#' so that it points to the analogous interactive geom.
#' @importFrom purrr detect_index
#' @noRd
layer_interactive <-
  function(layer_func, ..., interactive_geom = NULL) {
    args <- list(...)
    # we need to temporarily remove the interactive aesthetics if they exist
    # we could use check.aes = FALSE and check.param = FALSE but no fun there
    interactive_mapping <- NULL
    interactive_params <- NULL
    # find mapping argument (it might be unnamed, so check class)
    index <- purrr::detect_index(args, function(x) {
      inherits(x, "uneval")
    })
    # check if it contains interactive aesthetics
    if (index > 0 && has_interactive_attrs(args[[index]])) {
      interactive_mapping <- get_interactive_attrs(args[[index]])
      args[[index]] <- remove_interactive_attrs(args[[index]])
    }
    # check named parameters
    if (has_interactive_attrs(args)) {
      interactive_params <- get_interactive_attrs(args)
      args <- remove_interactive_attrs(args)
    }
    # call layer
    result <- do.call(layer_func, args)
    layer_ <- NULL
    if (is.list(result)) {
      # Like in geom_sf
      index <- purrr::detect_index(result, function(x) {
        inherits(x, "LayerInstance")
      })
      if (index > 0) {
        layer_ <- result[[index]]
      }
    } else if (inherits(result, "LayerInstance")) {
      layer_ <- result
    }
    # put back everything
    if (!is.null(layer_)) {
      if (is.null(interactive_geom)) {
        interactive_geom <- find_interactive_class(layer_$geom)
      }
      layer_$geom <- interactive_geom
      if (!is.null(interactive_mapping)) {
        layer_$mapping <- append_aes(layer_$mapping, interactive_mapping)
      }
      if (!is.null(interactive_params)) {
        layer_$aes_params <- append(layer_$aes_params, interactive_params)
      }
      if (is.list(result)) {
        result[[index]] <- layer_
      } else {
        result <- layer_
      }
    }
    result
  }

#' Finds an interactive geom class derived from a ggplot2 geom class.
#' @noRd
find_interactive_class <- function(geom, env = parent.frame()) {
  if (inherits(geom, "Geom")) {
    name <- class(geom)[1]
  } else if (is.character(geom) && length(geom) == 1) {
    name <- geom
    if (name == "histogram") {
      name <- "bar"
    }
  } else {
    stop("`geom` must be either a string or a Geom* object, ",
         "not ",
         obj_desc(geom),
         call. = FALSE)
  }
  if (!startsWith(name, "Geom")) {
    name <- paste0("Geom", camelize(name, first = TRUE))
  }
  if (!startsWith(name, "GeomInteractive")) {
    name <- sub("Geom", "GeomInteractive", name)
  }
  obj <- find_global(name, env = env)
  if (is.null(obj) || !inherits(obj, "Geom")) {
    stop("Can't find interactive geom function called \"",
         geom,
         "\"",
         call. = FALSE)
  } else {
    obj
  }
}
