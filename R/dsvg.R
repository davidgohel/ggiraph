#' @title SVG Graphics Driver
#'
#' @description This function produces SVG files (compliant to the current w3 svg XML standard)
#' where elements can be made interactive.
#'
#' @param file the file where output will appear.
#' @param height,width Height and width in inches.
#' @param bg Default background color for the plot (defaults to "white").
#' @param pointsize default point size.
#' @param standalone Produce a stand alone svg file? If \code{FALSE}, omits
#'   xml header and default namespace.
#' @param setdims If TRUE (the default), the svg node will have attributes width & height set
#' @param canvas_id svg id within HTML page.
#' @param fonts Named list of font names to be aliased with
#'   fonts installed on your system. If unspecified, the R default
#'   families \code{sans}, \code{serif}, \code{mono} and \code{symbol}
#'   are aliased to the family returned by \code{\link[gdtools]{match_family}()}.
#' @seealso \code{\link{Devices}}
#' @examples
#' fileout <- tempfile(fileext = ".svg")
#' dsvg(file = fileout)
#' plot(rnorm(10), main="Simple Example", xlab = "", ylab = "")
#' dev.off()
#' @keywords device
#' @useDynLib ggiraph,.registration = TRUE
#' @importFrom Rcpp sourceCpp
#' @importFrom gdtools raster_view
#' @export
dsvg <- function(file = "Rplots.svg", width = 6, height = 6, bg = "white",
                pointsize = 12, standalone = TRUE, setdims = TRUE, canvas_id = "svg_1",
                fonts = list()) {

  system_fonts <- validate_fonts( fonts )

  invisible(DSVG_(file=file, width=width, height=height, bg=bg,
                  pointsize=pointsize,
                  standalone=standalone,
                  setdims=setdims,
                  canvas_id=canvas_id,
                  aliases = list(system = system_fonts, user = list())
                  )
            )
}

