
#' @title Export a girafe object to SVG
#'
#' @description Export a girafe object to a standalone SVG document.
#'
#' @details
#' The exported svg will include all necessary Javascript scripts and CSS styles,
#' so that it be fully interactive by itself, when viewed in a browser or
#' embedded in an HTML document via the `embed`, `object` or `iframe` tag.
#'
#' @note
#' * The toolbar button 'save as png', is not supported inside the SVG.
#' * If the svg document is used in an `img` tag, it will not be interactive.
#'
#' @param x A girafe object created via [girafe()]
#' @param filename The filename for the SVG document
#' @param overwrite Overwrite file if it already exists?
#'
#' @example examples/girafe_export_svg.R
#' @seealso [girafe()]
#' @importFrom htmlwidgets getDependency
#' @importFrom purrr walk
#' @importFrom jsonlite toJSON
#' @export
girafe_export_svg <- function(x, filename, overwrite = FALSE) {
  if (!inherits(x, "girafe")) {
    abort("Not a girafe object")
  }
  if (!(rlang::is_string(filename) && nchar(trimws(filename)) > 0)) {
    abort("Not a valid filename: it must be a non-empty scalar character")
  }
  filename <- trimws(filename)
  if (file.exists(filename)) {
    if (file.info(filename)$isdir) {
      abort("Not a valid filename: supplied filename already exists and it's a directory.")
    }
    if (isFALSE(overwrite)) {
      abort("Supplied filename already exists. Use overwrite=TRUE to force overwriting it.")
    }
  }

  style_tag_start <- "<style type='text/css'>\n/*<![CDATA[*/"
  style_tag_end <- "/*]]>*/\n</style>"
  script_tag_start <- "<script type='text/javascript'>\n//<![CDATA["
  script_tag_end <- "//]]>\n</script>"

  f <- file(filename, "w")
  tryCatch(
    {
      # write everything but the closing svg tag
      writeLines(substring(x$x$html, 1, nchar(x$x$html) - 6), f)
      x$x$html <- ""
      x$x$js <- ""

      # include libs
      walk(getDependency("girafe", "ggiraph"), function(d) {
        if (d$name %in% c("ggiraphjs", "d3-bundle", "d3-lasso")) {
          if (!is.null(d$stylesheet)) {
            writeLines(style_tag_start, f)
            writeLines(read_file(file.path(d$src[[1]], d$stylesheet)), f)
            writeLines(style_tag_end, f)
          }
          if (!is.null(d$script)) {
            writeLines(script_tag_start, f)
            writeLines(read_file(file.path(d$src[[1]], d$script)), f)
            writeLines(script_tag_end, f)
          }
        }
      })

      # process and append the javascript template
      data <- toJSON(x$x, force = TRUE, auto_unbox = TRUE, null = "null", na = "null", pretty = TRUE)
      script <- read_file(system.file("htmlwidgets/girafe-standalone-svg.js", package = "ggiraph"))
      script <- sub(pattern = "\\{\\s*/\\*DATA HERE\\*/\\s*\\}", replacement = data, x = script)
      writeLines(script_tag_start, f)
      writeLines(script, f)
      writeLines(script_tag_end, f)

      writeLines("</svg>", f)
    },
    finally = close(f)
  )
  invisible()
}
