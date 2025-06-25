#' Calls a base ggplot2 geom/layer function and replaces the geom param
#' so that it points to the analogous interactive geom.
#' @importFrom purrr detect_index
#' @importFrom rlang list2
#' @noRd
layer_interactive <- function(
  layer_func,
  ...,
  interactive_geom = NULL,
  extra_interactive_params = NULL
) {
  args <- list2(...)
  # we need to temporarily remove the interactive aesthetics if they exist
  # we could use check.aes = FALSE and check.param = FALSE but no fun there
  interactive_mapping <- NULL
  interactive_params <- NULL
  # find mapping argument (it might be unnamed, so check class)
  index <- purrr::detect_index(args, function(x) {
    inherits(x, "uneval")
  })

  ipar <- get_default_ipar(extra_interactive_params)
  # check if it contains interactive aesthetics
  if (
    index > 0 &&
      has_interactive_attrs(args[[index]], ipar = ipar)
  ) {
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
    layer_$geom_params <- append(layer_$geom_params, list(.ipar = ipar))

    # set the defaults for any extra parameter
    default_aes_names <- names(layer_$geom$default_aes)
    missing_names <- setdiff(ipar, default_aes_names)
    if (length(missing_names) > 0) {
      defaults <- Map(missing_names, f = function(x) NULL)
      layer_$geom$default_aes <- append_aes(layer_$geom$default_aes, defaults)
    }

    if (is.list(result)) {
      result[[index]] <- layer_
    } else {
      result <- layer_
    }
  }
  result
}

#' Finds an interactive class derived from a ggplot2 geom/guide class.
#' @noRd
find_interactive_class <- function(
  gg,
  baseclass = c("Geom", "Guide"),
  env = parent.frame()
) {
  baseclass <- arg_match(baseclass)
  if (inherits(gg, baseclass)) {
    name <- class(gg)[1]
  } else if (is.character(gg) && length(gg) == 1) {
    name <- gg
    if (name == "histogram") {
      name <- "bar"
    }
  } else {
    abort(
      paste0(
        "`gg` must be either a string or a ",
        baseclass,
        "* object, not ",
        obj_desc(gg)
      ),
      call = NULL
    )
  }
  if (!startsWith(name, baseclass)) {
    name <- paste0(baseclass, camelize(name, first = TRUE))
  }
  baseinteractive <- paste0(baseclass, "Interactive")
  if (!startsWith(name, baseinteractive)) {
    name <- sub(baseclass, baseinteractive, name)
  }
  obj <- find_global(name, env = env)
  if (is.null(obj) || !inherits(obj, baseclass)) {
    abort(
      paste0(
        "Can't find interactive ",
        baseclass,
        " function based on ",
        as_label(gg)
      ),
      call = NULL
    )
  } else {
    obj
  }
}
