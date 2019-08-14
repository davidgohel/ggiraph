#' @title interactive sf objects
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{geom_sf}}.
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base geometry.
#' @examples
#' # add interactive sf objects to a ggplot -------
#' @example examples/geom_sf_interactive.R
#' @seealso \code{\link{girafe}}
#' @export
geom_sf_interactive <- function(...) {
  layer_interactive(geom_sf, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomInteractiveSf <- ggproto(
  "GeomInteractiveSf",
  GeomSf,
  default_aes = add_default_interactive_aes(GeomSf),
  draw_panel = function(data,
                        panel_params,
                        coord,
                        legend = NULL,
                        lineend = "butt",
                        linejoin = "round",
                        linemitre = 10) {
    if (!inherits(coord, "CoordSf")) {
      stop("geom_sf_interactive() must be used with coord_sf()", call. = FALSE)
    }

    coord <- coord$transform(data, panel_params)
    coord <- force_interactive_aes_to_char(coord)

    # Note: need to call this for each geometry separately
    grobs <- lapply(1:nrow(data), function(i) {
      interactive_sf_grob(
        coord[i, , drop = FALSE],
        lineend = lineend,
        linejoin = linejoin,
        linemitre = linemitre
      )
    })
    do.call("gList", grobs)
  },

  draw_key = function(data, params, size) {
    gr <- GeomSf$draw_key(data, params, size)
    add_interactive_attrs(gr, data, cl = NULL)
  }
)
