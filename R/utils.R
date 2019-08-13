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

force_interactive_aes_to_char <- function(data) {
  if (!is.null(data$tooltip) && !is.character(data$tooltip))
    data$tooltip <- as.character(data$tooltip)
  if (!is.null(data$onclick) && !is.character(data$onclick))
    data$onclick <- as.character(data$onclick)
  if (!is.null(data$data_id) && !is.character(data$data_id))
    data$data_id <- as.character(data$data_id)
  data
}

add_interactive_attrs <- function(gr, data, cl = NULL, data_attr = "data-id") {
  gr$tooltip <- data$tooltip
  gr$onclick <- data$onclick
  gr$data_id <- data$data_id
  gr$data_attr <- data_attr

  if( is.null(cl) ) {
    cl <- paste("interactive", class(gr)[1], "grob", sep = "_")
  }
  class(gr)[1] <- cl
  gr
}

add_default_interactive_aes <- function(geom = Geom) {
  def <- geom$default_aes
  def <- unclass(def)
  def <- append(def, list(tooltip = NULL, onclick = NULL, data_id = NULL) )
  do.call(aes_string, def)
}

interactive_attr_toxml <- function(x, ids = character(0), rows = NULL, attr_name = "data-id" ) {

  if( !is.null(x$data_attr)) attr_name <- x$data_attr
  if( is.null(rows) ){
    if( !is.null( x$tooltip ) ){
      rows <- seq_along(x$tooltip)
    } else if( !is.null( x$onclick ) ){
      rows <- seq_along(x$onclick)
    } else if( !is.null( x$data_id ) ){
      rows <- seq_along(x$data_id)
    }
  }

  if( length( ids ) > 0 ) {

    if( !is.null( x$tooltip ))
      set_attr( ids = as.integer( ids ), str = encode_cr(x$tooltip[rows]), attribute = "title" )
    if( !is.null( x$onclick ))
      set_attr( ids = as.integer( ids ), str = x$onclick[rows], attribute = "onclick" )
    if( !is.null( x$data_id )){
      set_attr( ids = as.integer( ids ), str = x$data_id[rows], attribute = attr_name )
    }
  }

  invisible()
}

grob_argnames <- function(x, grob ){
  intersect( names(formals(grob)), names(x) )
}

