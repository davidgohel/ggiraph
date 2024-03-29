#' Run plotting code and view svg in RStudio Viewer or web broswer.
#'
#' This is useful primarily for testing. Requires the `htmltools`
#' package.
#'
#' @param code Plotting code to execute.
#' @param ... Other arguments passed on to [dsvg()].
#' @export
#' @examples
#' \donttest{
#' dsvg_view(plot(1:10))
#' dsvg_view(hist(rnorm(100)))
#' }
#' @importFrom htmltools browsable HTML
dsvg_view <- function(code, ...) {
  path <- tempfile()
  devlength <- length(dev.list())
  dsvg(path, ...)
  tryCatch({
    code
  }, finally = {
    if (length(dev.list()) > devlength) {
      dev.off()
    }
  })
  if( interactive() ){
    doc <- read_file(path)
    browsable(HTML(as.character(doc)) )
  }
  else invisible()
}

