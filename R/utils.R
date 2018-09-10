.onLoad= function(libname, pkgname){

	options( "ggiwid" = list( svgid = 0 ) )
	invisible()
}


setGrobName <- function (prefix, grob)
{
	grob$name <- grobName(grob, prefix)
	grob
}

encode_cr <- function(x)
  gsub(pattern = "\n", replacement = "<br>", x = x)


#' @section Geoms:
#'
#' All `geom_*_interactive` functions (like `geom_point_interactive`) return a layer that
#' contains a `GeomInteractive*` object (like `GeomInteractivePoint`). The `Geom*`
#' object is responsible for rendering the data in the plot.
#'
#' See \code{\link[ggplot2]{Geom}} for more information.
#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @title ggproto classes for ggiraph
#' @name GeomInteractive
NULL

