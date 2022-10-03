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
#' @seealso [girafe_css_bicolor()], [girafe()]
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
  css <- c(
    paste0("/*GIRAFE CSS*/", validate_css(css, "css")),
    validate_css(text, "text", "text"),
    validate_css(point, "point", "circle"),
    validate_css(line, "line", c("line", "polyline")),
    validate_css(area, "area", c("rect", "polygon", "path")),
    validate_css(image, "image", "image")
  )
  paste(css[nzchar(css)], collapse = "\n")
}

#' @export
#' @title Helper for a 'girafe' css string
#'
#' @description It allows the creation of a css set of individual
#' styles for animation of 'girafe' elements. The used model is
#' based on a simple pattern that works *most of the time* for
#' girafe hover effects and selection effects.
#'
#' It sets properties based on a primary and a secondary color.
#'
#' @param primary,secondary colors used to define animations of
#' fill and stroke properties with text, lines, areas, points
#' and images in 'girafe' outputs.
#' @examples
#' library(ggplot2)
#' library(ggiraph)
#'
#' dat <- mtcars
#' dat$id <- "id"
#' dat$label <- "a line"
#' dat <- dat[order(dat$wt), ]
#'
#' p <- ggplot(
#'   data = dat,
#'   mapping = aes(
#'     x = wt, y = mpg, data_id = id, tooltip = label)) +
#'   geom_line_interactive(color = "white", size  = .75,
#'                         hover_nearest = TRUE) +
#'   theme_dark() +
#'   theme(plot.background = element_rect(fill="black"),
#'         panel.background = element_rect(fill="black"),
#'         text = element_text(colour = "white"),
#'         axis.text = element_text(colour = "white")
#'         )
#'
#' x <- girafe(
#'   ggobj = p,
#'   options = list(
#'     opts_hover(
#'       css = girafe_css_bicolor(
#'         primary = "yellow", secondary = "black"))
#' ))
#' if (interactive()) print(x)
#' @seealso [girafe_css()], [girafe()]
girafe_css_bicolor <- function(primary = "orange", secondary = "gray"){
  girafe_css(
    css = sprintf("fill:%s;stroke:%s;cursor:pointer;", primary, secondary),
    text = sprintf("stroke:none;fill:%s;", primary),
    line = sprintf("fill:none;stroke:%s;", primary),
    area = sprintf("fill:%s;stroke:none;", primary),
    point = sprintf("fill:%s;stroke:%s;", primary, secondary),
    image = sprintf("stroke:%s;", primary)
  )
}



#' Helper to check girafe_css argument
#' @noRd
#' @importFrom rlang is_scalar_character
validate_css <- function(css,
                         name,
                         tag = NULL) {
  if (is.null(css) || any(is.na(css)))
    css <- ""
  if (!is_string(css))
    abort(paste0("Argument `", name, "` must be a scalar character"), call = NULL)
  css <- trimws(css)
  if (nchar(css) > 0) {
    tag <- paste0(tag, "._CLASSNAME_", collapse = ", ")
    css <- paste(tag, "{", css, "}")
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
  } else if (!is_string(css)) {
    abort(name, ": css must be a scalar character", call = NULL)
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
