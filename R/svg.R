#' Reads the interactive attributes from xml and assigns them to their svg elements.
#' @noRd
#' @importFrom purrr walk
#' @importFrom xml2 xml_find_first xml_add_child xml_cdata
set_svg_attributes <- function(data, canvas_id) {
  comments <- xml_find_all(data, "//*[local-name() = 'comment']")
  if (length(comments) == 0) {
    return()
  }
  idprefix <- paste0(canvas_id, "_el_")
  env_data_hover <- new.env(parent = emptyenv())
  env_key_hover <- new.env(parent = emptyenv())
  env_theme_hover <- new.env(parent = emptyenv())
  env_data_selected <- new.env(parent = emptyenv())
  env_key_selected <- new.env(parent = emptyenv())
  env_theme_selected <- new.env(parent = emptyenv())
  errored <- 0
  walk(comments, function(comment) {
    targetIndex <- xml_attr(comment, "target")
    attrName <- xml_attr(comment, "attr")
    attrValue <- xml_text(comment)
    target <- xml_find_first(data,
                             paste0("//*[@id='", idprefix, targetIndex, "']"))
    if (!inherits(target, "xml_missing")) {
      if (attrName == "hover_css") {
        # collect unique combinations of hover_css per data/key/theme id
        collect_css(target,
                    attrValue,
                    env_data_hover,
                    env_key_hover,
                    env_theme_hover)

      } else if (attrName == "selected_css") {
        # collect unique combinations of selected_css per data/key/theme id
        collect_css(target,
                    attrValue,
                    env_data_selected,
                    env_key_selected,
                    env_theme_selected)

      } else {
        # set the attribute directly
        xml_attr(target, attrName) <- attrValue
      }
    } else {
      errored <<- errored + 1
    }
  })
  # now place the individual styles
  css <- make_css(env_data_hover,
                  "data-id",
                  "hover_",
                  canvas_id)
  css <- c(css,
           make_css(env_key_hover,
                    "key-id",
                    "hover_key_",
                    canvas_id))
  css <- c(css,
           make_css(env_theme_hover,
                    "theme-id",
                    "hover_theme_",
                    canvas_id))
  css <- c(css,
           make_css(env_data_selected,
                    "data-id",
                    "selected_",
                    canvas_id))
  css <- c(css,
           make_css(env_key_selected,
                    "key-id",
                    "selected_key",
                    canvas_id))
  css <- c(css,
           make_css(env_theme_selected,
                    "theme-id",
                    "selected_theme",
                    canvas_id))
  if (length(css) > 0) {
    style_tag <-
      xml_add_child(data, "style", type = "text/css", .where = 0)
    xml_add_child(style_tag, xml_cdata(paste(css, collapse = '\n')))
  }

  # clear the comments
  xml_remove(comments)
  if (errored > 0) {
    stop("Could not set svg attributes for some elements (",
         errored,
         " cases)")
  }
}

collect_css <- function(target,
                        attrValue,
                        env_data,
                        env_key,
                        env_theme) {
  data_id <- xml_attr(target, "data-id")
  key_id <- xml_attr(target, "key-id")
  theme_id <- xml_attr(target, "theme-id")
  if (!is.null(data_id) && !is.na(data_id)) {
    env_data[[data_id]] <- attrValue
  } else if (!is.null(key_id) && !is.na(key_id)) {
    env_key[[key_id]] <- attrValue
  } else if (!is.null(theme_id) && !is.na(theme_id)) {
    env_theme[[theme_id]] <- attrValue
  }
}

make_css <- function(envir, data_attr, cls_prefix, canvas_id) {
  lapply(ls(envir, all.names = TRUE, sorted = FALSE), function(x) {
    check_css(
      css = get(x, envir = envir),
      default = "",
      cls_prefix = cls_prefix,
      canvas_id = canvas_id,
      filter = paste0("[", data_attr, " = \"", x , "\"]")
    )
  })
}

#' CSS creation helper
#'
#' It allows specifying individual styles for various SVG elements.
#'
#' @param css The generic css style
#' @param text Override style for text elements (svg:text)
#' @param point Override style for point elements (svg:circle)
#' @param line Override style for line elements (svg:line, svg:polyline)
#' @param area Override style for area elements (svg:rect, svg:polygon, svg:path)
#'
#' @return css as scalar character
#' @examples
#' library(ggiraph)
#'
#' girafe_css(
#'   css = "fill:orange;stroke:gray;",
#'   text = "stroke:none; font-size: larger",
#'   line = "fill:none",
#'   area = "stroke-width:3px",
#'   point = "stroke-width:3px"
#' )
#' @export
girafe_css <- function(css,
                       text = NULL,
                       point = NULL,
                       line = NULL,
                       area = NULL) {
  css <- paste("/*GIRAFE CSS*/ ._CLASSNAME_ {", css, "}\n")
  if (!is.null(text))
    css <- paste(css, paste("text._CLASSNAME_ {", text, "}\n"))
  if (!is.null(point))
    css <- paste(css, paste("circle._CLASSNAME_ {", point, "}\n"))
  if (!is.null(line))
    css <- paste(css,
                 paste("line._CLASSNAME_, polyline._CLASSNAME_ {", line, "}\n"))
  if (!is.null(area))
    css <- paste(css,
                 paste(
                   "rect._CLASSNAME_, polygon._CLASSNAME_, path._CLASSNAME_ {",
                   area,
                   "}\n"
                 ))
  return(css)
}

#' Helper to check css argument, given in other functions
#' @noRd
#' @importFrom rlang is_scalar_character
check_css <- function(css,
                      default,
                      cls_prefix,
                      name = cls_prefix,
                      canvas_id = "SVGID_",
                      filter = NULL) {
  if (is.null(css)) {
    css <- default
  } else if (!is_scalar_character(css)) {
    stop(name, ": css must be a scalar character", call. = FALSE)
  }
  pattern = "\\/\\*GIRAFE CSS\\*\\/"
  if (!grepl(pattern, css)) {
    css <- girafe_css(css)
  }
  css <- gsub("_CLASSNAME_", paste0(cls_prefix, canvas_id, filter), css)
  css <- gsub(pattern, "", css)
  css
}
