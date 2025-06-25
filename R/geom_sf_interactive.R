#' @title Create interactive sf objects
#'
#' @description
#' These geometries are based on [ggplot2::geom_sf()], [ggplot2::geom_sf_label()]
#' and [ggplot2::geom_sf_text()]. See the documentation for those functions for
#' more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters].
#' @inheritSection interactive_parameters Details for interactive geom functions
#' @examples
#' # add interactive sf objects to a ggplot -------
#' @example examples/geom_sf_interactive.R
#' @seealso [girafe()]
#' @export
geom_sf_interactive <- function(...) {
  layer_interactive(geom_sf, ...)
}

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @importFrom purrr flatten
GeomInteractiveSf <- ggproto(
  "GeomInteractiveSf",
  GeomSf,
  default_aes = add_default_interactive_aes(GeomSf),
  parameters = interactive_geom_parameters,
  draw_key = interactive_geom_draw_key,
  draw_panel = function(
    data,
    panel_params,
    coord,
    legend = NULL,
    lineend = "butt",
    linejoin = "round",
    linemitre = 10,
    na.rm = TRUE,
    .ipar = IPAR_NAMES
  ) {
    # call original draw_panel for each data row/geometry
    # this way multi geometries are handled too
    useflatten <- FALSE
    grobs <- lapply(1:nrow(data), function(i) {
      row <- data[i, , drop = FALSE]
      gr <- GeomSf$draw_panel(
        row,
        panel_params,
        coord,
        legend = legend,
        lineend = lineend,
        linejoin = linejoin,
        linemitre = linemitre,
        na.rm = na.rm
      )
      if (inherits(gr, "gList")) {
        # grid v<3.6.0
        useflatten <<- TRUE
        for (i in seq_along(gr)) {
          gr[[i]] <- add_interactive_attrs(gr[[i]], row, ipar = .ipar)
        }
        gr
      } else {
        add_interactive_attrs(gr, row, ipar = .ipar)
      }
    })
    if (useflatten) {
      grobs <- flatten(grobs)
    }
    do.call("gList", grobs)
  }
)

#' @export
#' @rdname geom_sf_interactive
geom_sf_label_interactive <- function(...) {
  layer_interactive(geom_sf_label, ..., interactive_geom = GeomInteractiveLabel)
}

#' @export
#' @rdname geom_sf_interactive
geom_sf_text_interactive <- function(...) {
  layer_interactive(geom_sf_text, ..., interactive_geom = GeomInteractiveText)
}
