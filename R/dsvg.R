#' @title SVG Graphics Driver
#'
#' @description This function produces SVG files (compliant to the current w3 svg XML standard)
#' where elements can be made interactive.
#'
#' In order to generate the output, used fonts must be available on the computer used to create the svg,
#' used fonts must also be available on the computer used to render the svg.
#'
#' @param file the file where output will appear.
#' @param height,width Height and width in inches.
#' @param bg Default background color for the plot (defaults to "white").
#' @param pointsize default point size.
#' @param standalone Produce a stand alone svg file? If `FALSE`, omits
#'   xml header and default namespace.
#' @param setdims If `TRUE` (the default), the svg node will have attributes width & height set.
#' @param title A label for accessibility purposes (aria-label/aria-labelledby).
#' Be aware that when using this, the browser will use it as a tooltip for the whole svg and
#' it may class with the interactive elements' tooltip.
#' @param desc A longer description for accessibility purposes (aria-description/aria-describedby).
#' @param canvas_id svg id within HTML page.
#' @param fonts Named list of font names to be aliased with
#' fonts installed on your system. If unspecified, the R default
#' families "sans", "serif", "mono" and "symbol"
#' are aliased to the family returned by [match_family()].
#'
#' If fonts are available, the default mapping will use these values:
#'
#' | R family | Font on Windows    | Font on Unix | Font on Mac OS |
#' |----------|--------------------|--------------|----------------|
#' | `sans`   | Arial              | DejaVu Sans  | Helvetica      |
#' | `serif`  | Times New Roman    | DejaVu serif | Times          |
#' | `mono`   | Courier            | DejaVu mono  | Courier        |
#' | `symbol` | Symbol             | DejaVu Sans  | Symbol         |
#'
#' As an example, using `fonts = list(sans = "Roboto")` would make the
#' default font "Roboto" as many ggplot theme are using `theme_minimal(base_family="")` or
#' `theme_minimal(base_family="sans")`.
#'
#' You can also use theme_minimal(base_family="Roboto").
#' @seealso [Devices]
#' @examples
#' fileout <- tempfile(fileext = ".svg")
#' dsvg(file = fileout)
#' plot(rnorm(10), main="Simple Example", xlab = "", ylab = "")
#' dev.off()
#' @keywords device
#' @useDynLib ggiraph,.registration = TRUE
#' @importFrom rlang is_string
#' @importFrom Rcpp sourceCpp
#' @importFrom systemfonts match_font
#' @export
dsvg <- function(file = "Rplots.svg", width = 6, height = 6, bg = "white",
                 pointsize = 12, standalone = TRUE, setdims = TRUE, canvas_id = "svg_1",
                 title = NULL, desc = NULL,
                 fonts = list()) {

  if (!is_valid_string_non_empty(file)) {
    abort("`file` must be a non-empty scalar character", call = NULL)
  }
  if (!is_valid_number(width) || width <= 0) {
    abort("`width` must be a scalar positive number", call = NULL)
  }
  if (!is_valid_number(height) || height <= 0) {
    abort("`height` must be a scalar positive number", call = NULL)
  }
  if (!is_valid_string_non_empty(bg)) {
    abort("`bg` must be a non-empty scalar character", call = NULL)
  }
  if (!is_valid_number(pointsize) || pointsize <= 0) {
    abort("`pointsize` must be a scalar positive number", call = NULL)
  }
  if (!is_valid_logical(standalone)) {
    abort("`standalone` must be a scalar logical", call = NULL)
  }
  if (!is_valid_logical(setdims)) {
    abort("`setdims` must be a scalar logical", call = NULL)
  }
  if (!is_valid_string_non_empty(canvas_id)) {
    abort("`canvas_id` must be a non-empty scalar character", call = NULL)
  }
  if (!is_valid_string_non_empty(title)) {
    title <- ""
  }
  if (!is_valid_string_non_empty(desc)) {
    desc <- ""
  }
  if (!is.list(fonts)) {
    abort("`fonts` must be a list", call = NULL)
  }

  fonts_list <- validated_fonts(fonts)

  invisible(DSVG_(
    filename = file,
    width = width, height = height,
    canvas_id = canvas_id,
    title = title, desc = desc,
    standalone = standalone, setdims = setdims,
    pointsize = pointsize,
    bg = bg,
    aliases = list(system = fonts_list)
  ))
}

