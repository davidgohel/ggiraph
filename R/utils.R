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
  htmltools::htmlEscape(
    text = gsub(
      pattern = "\n",
      replacement = "<br>",
      x = x
    ),
    attribute = TRUE
  )


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

#' Ensures that interactive attributes are characters.
#' @noRd
force_interactive_aes_to_char <- function(data) {
  if (!is.null(data$tooltip) && !is.character(data$tooltip)) {
    data$tooltip <- as.character(data$tooltip)
  }
  if (!is.null(data$onclick) && !is.character(data$onclick)) {
    data$onclick <- as.character(data$onclick)
  }
  if (!is.null(data$data_id) && !is.character(data$data_id)) {
    data$data_id <- as.character(data$data_id)
  }
  data
}

#' Copies interactive attributes from one object to the other.
#' and returns the result
#' @noRd
copy_interactive_attrs <- function(src, dest, useList = FALSE, ...) {
  if (useList == TRUE) {
    if (!is.null(src$tooltip)) {
      dest$tooltip <-
        unlist(mapply(rep, as.character(src$tooltip), ...))
    }
    if (!is.null(src$onclick)) {
      dest$onclick <-
        unlist(mapply(rep, as.character(src$onclick), ...))
    }
    if (!is.null(src$data_id)) {
      dest$data_id <-
        unlist(mapply(rep, as.character(src$data_id), ...))
    }
  } else {
    if (!is.null(src$tooltip)) {
      dest$tooltip <- rep(as.character(src$tooltip), ...)
    }
    if (!is.null(src$onclick)) {
      dest$onclick <- rep(as.character(src$onclick), ...)
    }
    if (!is.null(src$data_id)) {
      dest$data_id <- rep(as.character(src$data_id), ...)
    }
  }
  dest
}

#' Checks if passed object contains interactive attributes.
#' @noRd
has_interactive_attrs <- function(x) {
  !is.null(x$tooltip) || !is.null(x$onclick) || !is.null(x$data_id)
}

#' Gathers the interactive attributes that may exist in an object.
#' @noRd
collect_interactive_attrs <- function(x) {
  x[intersect(names(x), c("tooltip", "onclick", "data_id"))]
}

#' Removes the interactive attributes from an object.
#' @noRd
remove_interactive_attrs <- function(x) {
  x$tooltip <- NULL
  x$onclick <- NULL
  x$data_id <- NULL
  x
}

#' Add the interactive attributes from a data object to a grob.
#' and changes its class
#' @noRd
add_interactive_attrs <- function(gr,
                                  data,
                                  cl = NULL,
                                  data_attr = "data-id") {
  if( inherits(gr, "gTree") ){
    for(i in seq_along(gr$children)){
      gr$children[[i]] <- add_interactive_attrs(gr = gr$children[[i]], data = data, cl = cl, data_attr = data_attr)
    }
    return(gr)
  }
  gr$tooltip <- data$tooltip
  gr$onclick <- data$onclick
  gr$data_id <- data$data_id
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
  append_aes(
    geom$default_aes,
    list(
      tooltip = NULL,
      onclick = NULL,
      data_id = NULL
    )
  )
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
  if( length(ids) < 1 )
    return(invisible())

  if (!is.null(x$data_attr)) {
    attr_name <- x$data_attr
  }
  if (is.null(rows)) {
    if (!is.null(x$tooltip)) {
      rows <- seq_along(x$tooltip)
    } else if (!is.null(x$onclick)) {
      rows <- seq_along(x$onclick)
    } else if (!is.null(x$data_id)) {
      rows <- seq_along(x$data_id)
    }
  }

  if (!is.null(x$tooltip)) {
    set_attr(
      ids = as.integer(ids),
      str = encode_cr(x$tooltip[rows]),
      attribute = "title"
    )
  }
  if (!is.null(x$onclick)) {
    set_attr(
      ids = as.integer(ids),
      str = x$onclick[rows],
      attribute = "onclick"
    )
  }
  if (!is.null(x$data_id)) {
    set_attr(
      ids = as.integer(ids),
      str = x$data_id[rows],
      attribute = attr_name
    )
  }
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
      interactive_mapping <- collect_interactive_attrs(args[[index]])
      args[[index]] <- remove_interactive_attrs(args[[index]])
    }
    # check named parameters
    if (has_interactive_attrs(args)) {
      interactive_params <- collect_interactive_attrs(args)
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
      call. = FALSE
    )
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
      call. = FALSE
    )
  } else {
    obj
  }
}
