#' Run plotting code and view svg in RStudio Viewer or web broswer.
#'
#' This is useful primarily for testing. Requires the \code{htmltools}
#' package.
#'
#' @param code Plotting code to execute.
#' @param ... Other arguments passed on to \code{\link{dsvg}}.
#' @export
#' @examples
#' \donttest{
#' dsvg_view(plot(1:10))
#' dsvg_view(hist(rnorm(100)))
#' }
#' @importFrom htmltools browsable HTML
dsvg_view <- function(code, ...) {
  path <- tempfile()
  dsvg(path, ...)
  tryCatch(code,
           finally = dev.off()
  )
  if( interactive() ){
    doc <- paste0(readLines(path, encoding = "UTF-8"), collapse = "\n")
    browsable(HTML(as.character(doc)) )
  }
  else invisible()
}

