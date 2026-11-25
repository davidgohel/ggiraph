#' Run plotting code and view svg in RStudio Viewer or web browser
#'
#' @description
#' `dsvg_view()` is deprecated: draw with [dsvg()] directly, or display an
#' interactive graphic with [girafe()].
#'
#' @param code Plotting code to execute.
#' @param ... Other arguments passed on to [dsvg()].
#' @keywords internal
#' @export
#' @importFrom htmltools browsable HTML
dsvg_view <- function(code, ...) {
  cli::cli_warn(
    c(
      "!" = "{.fn dsvg_view} is deprecated.",
      "i" = "Draw with {.fn dsvg} directly, or display an interactive graphic with {.fn girafe}."
    ),
    .frequency = "regularly",
    .frequency_id = "ggiraph_no_more_dsvg_view"
  )
  path <- tempfile()
  devlength <- length(dev.list())
  dsvg(path, ...)
  tryCatch(
    {
      code
    },
    finally = {
      if (length(dev.list()) > devlength) {
        dev.off()
      }
    }
  )
  if (interactive()) {
    doc <- read_file(path)
    browsable(HTML(as.character(doc)))
  } else {
    invisible()
  }
}
