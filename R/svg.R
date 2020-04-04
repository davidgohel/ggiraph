#' CSS creation helper
#'
#' It allows specifying individual styles for various SVG elements.
#'
#' @param css The generic css style
#' @param text Override style for text elements (svg:text)
#' @param point Override style for point elements (svg:circle)
#' @param line Override style for line elements (svg:line, svg:polyline)
#' @param area Override style for area elements (svg:rect, svg:polygon, svg:path)
#' @param image Override style for image elements (svg:image)
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
#'   point = "stroke-width:3px",
#'   image = "outline:2px red"
#' )
#' @export
girafe_css <- function(css,
                       text = NULL,
                       point = NULL,
                       line = NULL,
                       area = NULL,
                       image = NULL) {
  css <- paste0("/*GIRAFE CSS*/", validate_css(css, "css"))
  css <- paste0(css, validate_css(text, "text", "text"))
  css <- paste0(css, validate_css(point, "point", "circle"))
  css <- paste0(css,
                validate_css(line, "line", c("line", "polyline")))
  css <- paste0(css,
                validate_css(area, "line", c("rect", "polygon", "path")))
  css <- paste0(css, validate_css(image, "image", "image"))
  css
}

#' Helper to check girafe_css argument
#' @noRd
#' @importFrom rlang is_scalar_character
validate_css <- function(css,
                         name,
                         tag = NULL) {
  if (is.null(css) || is.na(css))
    css <- ""
  if (!is_scalar_character(css))
    stop(paste0("Argument `", name, "` must be a scalar character"), call. = FALSE)
  css <- trimws(css)
  if (nchar(css) > 0) {
    tag <- paste0(tag, "._CLASSNAME_", collapse = ", ")
    css <- paste(tag, "{", css, "}\n")
  }
  css
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

#' Helper to check css interactive parameter (vectorized)
#' @noRd
check_css_attr <- function(css) {
  pattern = "\\/\\*GIRAFE CSS\\*\\/"
  unlist(lapply(css, function(x) {
    if (!grepl(pattern, x))
      x <- girafe_css(x)
    gsub(pattern, "", x)
  }))
}
