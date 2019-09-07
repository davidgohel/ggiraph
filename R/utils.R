# Include generic helpers from ggplot2
#' @include utils_ggplot2.R
#' @include utils_ggplot2_performance.R

# FIXME
# dapply is in ggplot2/compat-plyr.R, but if we include that file,
# it causes more issues as it depends ggplot2 globals.
# dapply is only used in GeomInteractivePath.
dapply <- ggplot2:::dapply

# Include parameters
#' @include ipar.R


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


#' Generates a default aesthetics mapping for an interactive class
#' by copying the default aes and appending the interactive attrs.
#' @noRd
add_default_interactive_aes <- function(geom = Geom,
                                        defaults = IPAR_DEFAULTS) {
  append_aes(geom$default_aes, defaults)
}

#' Appends a list of attributes to an aesthetic mapping.
#' @noRd
append_aes <- function(mapping, lst) {
  aes_new <- structure(lst, class = "uneval")
  mapping[names(aes_new)] <- aes_new
  mapping
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
layer_interactive <- function(layer_func,
                              ...,
                              interactive_geom = NULL,
                              ipar = IPAR_NAMES) {
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
  if (index > 0 &&
      has_interactive_attrs(args[[index]], ipar = ipar)) {
    interactive_mapping <-
      get_interactive_attrs(args[[index]], ipar = ipar)
    args[[index]] <-
      remove_interactive_attrs(args[[index]], ipar = ipar)
  }
  # check named parameters
  if (has_interactive_attrs(args, ipar = ipar)) {
    interactive_params <- get_interactive_attrs(args, ipar = ipar)
    args <- remove_interactive_attrs(args, ipar = ipar)
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
