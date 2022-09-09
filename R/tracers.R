#' @import graphics
#' @importFrom grDevices dev.cur dev.list

#' @title trace on id collection
#'
#' @description Start collecting id of an dsvg device.
#' @noRd
dsvg_tracer_on <- function() {
  result <- NULL
  if (length(dev.list()) > 0 && .Device == "dsvg_device") {
    dev_num <- as.integer(dev.cur() - 1L)
    result <- set_tracer_on(dn = dev_num)
  }
  invisible(result)
}

#' @title trace off id collection
#'
#' @description get collected id of an dsvg device and
#' stop collecting.
#' @return graphical elements id as integer values.
#' @noRd
dsvg_tracer_off <- function() {
  ids <- integer(0)
  if (length(dev.list()) > 0 && .Device == "dsvg_device") {
    dev_num <- as.integer(dev.cur() - 1L)
    ids <- collect_id(dev_num)
    set_tracer_off(dn = dev_num)
  }
  ids
}

#' @title set attributes to graphical elements
#'
#' @description set attributes with javascript instructions
#' to graphical elements.
#' @param name name of the attribute to set.
#' @param ids integer vector of graphical elements identifiers (returned by
#' [dsvg_tracer_off()]).
#' @param values values to set for the attribute.
#' @noRd
set_attr <- function(name, ids, values) {
  result <- NULL
  if (length(dev.list()) > 0 && .Device == "dsvg_device") {
    if (is.factor(values)) {
      values <- as.character(values)
    }
    if (is.factor(name)) {
      name <- as.character(name)
    }

    stopifnot(is.character(name))
    stopifnot(length(name) == 1)
    stopifnot(is.character(values))
    stopifnot(is.numeric(ids))
    if (any(grepl(pattern = "'", values))) {
      stop("Attribute values cannot contain single quote \"'\".")
    }

    if (length(values) == 1 && length(ids) > 1) {
      values <- rep(values, length(ids))
    }
    if (length(ids) %% length(values) < 1 &&
      length(ids) != length(values)) {
      values <- rep(values, each = length(ids) %/% length(values))
    }

    if (length(ids) != length(values)) {
      warning(
        "Failed setting attribute '", name, "', ",
        "mismatched lengths of ids and values ",
        "(most often, it occurs because of clipping or because of NAs in data)"
      )
    } else {
      dev_num <- as.integer(dev.cur() - 1L)
      result <- add_attribute(
        dn = dev_num,
        name = name,
        ids = as.integer(ids),
        values = values
      )
    }
  }
  invisible(result)
}
