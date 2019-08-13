setGrobName <- function (prefix, grob)
{
	grob$name <- grobName(grob, prefix)
	grob
}

#' @importFrom htmltools htmlEscape
encode_cr <- function(x)
  htmltools::htmlEscape(text = gsub(
    pattern = "\n",
    replacement = "<br>",
    x = x
  ),
  attribute = TRUE)


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

