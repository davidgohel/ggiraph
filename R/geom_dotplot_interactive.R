#' Create interactive dot plot
#'
#' @description
#' This geometry is based on [geom_dotplot()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' library(ggplot2)
#' library(ggiraph)
#'
#' gg_point = ggplot(
#'   data = mtcars,
#'   mapping = aes(
#'     x = factor(vs), fill = factor(cyl), y = mpg,
#'     tooltip = row.names(mtcars))) +
#'   geom_dotplot_interactive(binaxis = "y",
#'     stackdir = "center", position = "dodge")
#'
#' x <- girafe(ggobj = gg_point)
#' if( interactive() ) print(x)
#' @seealso [girafe()]
#' @export
geom_dotplot_interactive <- function(...)
  layer_interactive(geom_dotplot, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveDotplot <- ggproto(
  "GeomInteractiveDotplot",
  GeomDotplot,
  default_aes = add_default_interactive_aes(GeomDotplot),
  draw_key = function(data, params, size) {
    gr <- GeomDotplot$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_group = function (data, ...)
  {
    zz <- GeomDotplot$draw_group(data, ...)
    add_interactive_attrs(zz, data)
  }
)

#' @export
makeContext.interactive_dotstack_grob <- function(x, recording = TRUE) {
  gr <- NextMethod()
  gr <- add_interactive_attrs(gr, x)
  gr
}

