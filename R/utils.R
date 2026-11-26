#' @importFrom MASS kde2d
#' @importFrom rlang arg_match is_named %||%
#' @importFrom rlang check_bool check_number_decimal check_string
#' @importFrom rlang caller_arg caller_env
# Functions copied by extensions with getFromNamespace() (add_interactive_attrs(),
# scale_interactive()...) must not call `pkg::fun()` of a package that the
# extensions do not import: their R CMD check warns ("'::' or ':::' import
# not declared from"). They call imported functions instead.
#' @importFrom cli cli_abort cli_warn
# Include generic helpers from ggplot2
#' @include utils_ggplot2.R
#' @include utils_ggplot2_performance.R

# Include parameters
#' @include ipar.R

#' Encodes the attribute value designated for tooltip
#' @importFrom htmltools htmlEscape
#' @noRd
encode_cr <- function(x) {
  newlines_pattern <- "(\r\n|\r|\n)"
  # quick check to see if we need to replace newline chars
  # exclude text marked as html with htmltools::HTML
  replace_newlines <- !inherits(x, "html") && any(grepl(newlines_pattern, x))
  if (replace_newlines) {
    x <- sapply(x, function(t) {
      # text might be markup anyway, check for opening/closing tags at start/end
      if (
        grepl(newlines_pattern, t) &&
          !(grepl("^\\s*<\\w+.*?/?>", t) && grepl("</?\\w+.*?/?>\\s*$", t))
      ) {
        gsub(newlines_pattern, replacement = "<br/>", x = t)
      } else {
        t
      }
    })
  }
  htmltools::htmlEscape(x, attribute = TRUE)
}


#' @section Geoms:
#'
#' All `geom_*_interactive` functions (like `geom_point_interactive`) return a layer that
#' contains a `GeomInteractive*` object (like `GeomInteractivePoint`). The `Geom*`
#' object is responsible for rendering the data in the plot.
#'
#' See [Geom][ggplot2::Geom()] for more information.
#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @title ggproto classes for ggiraph
#' @name GeomInteractive
#' @keywords internal
NULL


#' Generates a default aesthetics mapping for an interactive class
#' by copying the default aes and appending the interactive attrs.
#' @noRd
add_default_interactive_aes <- function(geom = Geom, defaults = IPAR_DEFAULTS) {
  append_aes(geom$default_aes, defaults)
}

#' Override of default parameters function in order to:
#' - Get the parameters/arguments from super class
#' - Add the extra .ipar argument
#' @noRd
interactive_geom_parameters <- function(self, extra = FALSE) {
  parent_params <- self$super()$parameters(extra = extra)
  panel_args <- names(ggproto_formals(self$draw_panel))
  group_args <- names(ggproto_formals(self$draw_group))
  if (
    (".ipar" %in% panel_args || ".ipar" %in% group_args) &&
      !(".ipar" %in% parent_params)
  ) {
    c(parent_params, ".ipar")
  } else {
    parent_params
  }
}

#' Override of default draw_key function, in order to add
#' the interactive attrs
#' @noRd
interactive_geom_draw_key <- function(self, data, params, size) {
  gr <- self$super()$draw_key(data, params, size)
  add_interactive_attrs(gr, data, data_attr = "key-id", ipar = get_ipar(params))
}

#' Appends a list of attributes to an aesthetic mapping.
#' @noRd
append_aes <- function(mapping, lst) {
  mapping[names(lst)] <- lst
  mapping
}

#' Returns the contents of a file as text
#' @noRd
read_file <- function(path, ..., encoding = "UTF-8", warn = FALSE) {
  paste0(
    readLines(con = path, encoding = encoding, warn = warn, ...),
    collapse = "\n"
  )
}

#' @importFrom rlang is_string
is_valid_string <- function(x) {
  is_string(x) && nzchar(x)
}
is_valid_string_non_empty <- function(x) {
  is_valid_string(x) && nzchar(trimws(x))
}


# a number strictly positive (check_number_decimal() has no exclusive bound)
check_number_positive <- function(x, ..., arg = caller_arg(x), call = caller_env()) {
  check_number_decimal(x, ..., min = 0, arg = arg, call = call)
  if (x == 0) {
    cli::cli_abort("{.arg {arg}} must be larger than 0, not 0.", call = call)
  }
  invisible(NULL)
}

# a string made only of spaces is refused, as an empty one (after
# check_string(), which accepts it)
check_not_blank <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (!is.null(x) && !nzchar(trimws(x))) {
    cli::cli_abort("{.arg {arg}} must not be blank.", call = call)
  }
  invisible(NULL)
}

#' Rows drawn by `GeomSegment$draw_panel()`
#' @details
#' `GeomSegment$draw_panel()` removes the rows with a missing position,
#' linetype or linewidth before drawing. A geom that wraps a method of
#' 'ggplot2' drawing segments (linerange, pointrange...) gives the
#' interactive attributes of the segments drawn, not of the removed rows.
#' @noRd
segment_drawn_data <- function(data) {
  vars <- intersect(
    c("x", "y", "xmin", "xmax", "ymin", "ymax", "xend", "yend", "linetype", "linewidth"),
    names(data)
  )
  vctrs::vec_slice(data, stats::complete.cases(data[vars]))
}
