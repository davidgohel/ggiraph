#' Calls a base ggplot2 geom/layer function and replaces the geom param
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
