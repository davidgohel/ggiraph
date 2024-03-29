% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dsvg.R
\name{dsvg}
\alias{dsvg}
\title{SVG Graphics Driver}
\usage{
dsvg(
  file = "Rplots.svg",
  width = 6,
  height = 6,
  bg = "white",
  pointsize = 12,
  standalone = TRUE,
  setdims = TRUE,
  canvas_id = "svg_1",
  title = NULL,
  desc = NULL,
  fonts = list()
)
}
\arguments{
\item{file}{the file where output will appear.}

\item{height, width}{Height and width in inches.}

\item{bg}{Default background color for the plot (defaults to "white").}

\item{pointsize}{default point size.}

\item{standalone}{Produce a stand alone svg file? If \code{FALSE}, omits
xml header and default namespace.}

\item{setdims}{If \code{TRUE} (the default), the svg node will have attributes width & height set.}

\item{canvas_id}{svg id within HTML page.}

\item{title}{A label for accessibility purposes (aria-label/aria-labelledby).
Be aware that when using this, the browser will use it as a tooltip for the whole svg and
it may class with the interactive elements' tooltip.}

\item{desc}{A longer description for accessibility purposes (aria-description/aria-describedby).}

\item{fonts}{Named list of font names to be aliased with
fonts installed on your system. If unspecified, the R default
families "sans", "serif", "mono" and "symbol"
are aliased to the family returned by \code{\link[=match_family]{match_family()}}.

If fonts are available, the default mapping will use these values:\tabular{llll}{
   R family \tab Font on Windows \tab Font on Unix \tab Font on Mac OS \cr
   \code{sans} \tab Arial \tab DejaVu Sans \tab Helvetica \cr
   \code{serif} \tab Times New Roman \tab DejaVu serif \tab Times \cr
   \code{mono} \tab Courier \tab DejaVu mono \tab Courier \cr
   \code{symbol} \tab Symbol \tab DejaVu Sans \tab Symbol \cr
}


As an example, using \code{fonts = list(sans = "Roboto")} would make the
default font "Roboto" as many ggplot theme are using \code{theme_minimal(base_family="")} or
\code{theme_minimal(base_family="sans")}.

You can also use theme_minimal(base_family="Roboto").}
}
\description{
This function produces SVG files (compliant to the current w3 svg XML standard)
where elements can be made interactive.

In order to generate the output, used fonts must be available on the computer used to create the svg,
used fonts must also be available on the computer used to render the svg.
}
\examples{
fileout <- tempfile(fileext = ".svg")
dsvg(file = fileout)
plot(rnorm(10), main="Simple Example", xlab = "", ylab = "")
dev.off()
}
\seealso{
\link{Devices}
}
\keyword{device}
