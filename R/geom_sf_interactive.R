#' @title Create interactive sf objects
#'
#' @description
#' These geometries are based on [geom_sf()], [geom_sf_label()] and [geom_sf_text()].
#' See the documentation for those functions for more details.
#'
#' @param ... arguments passed to base function,
#' plus any of the [interactive_parameters()].
#' @inheritSection interactive_parameters Details for geom_*_interactive functions
#' @examples
#' # add interactive sf objects to a ggplot -------
#' @example examples/geom_sf_interactive.R
#' @seealso [girafe()]
#' @export
geom_sf_interactive <- function(...)
  layer_interactive(geom_sf, ...)

#' @rdname ggiraph-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @importFrom purrr flatten
GeomInteractiveSf <- ggproto(
  "GeomInteractiveSf",
  GeomSf,
  default_aes = add_default_interactive_aes(GeomSf),
  draw_key = function(data, params, size) {
    gr <- GeomSf$draw_key(data, params, size)
    add_interactive_attrs(gr, data, data_attr = "key-id")
  },
  draw_panel = function(data,
                        panel_params,
                        coord,
                        legend = NULL,
                        lineend = "butt",
                        linejoin = "round",
                        linemitre = 10,
                        na.rm = TRUE) {
    data <- force_interactive_aes_to_char(data)
    # call original draw_panel for each data row/geometry
    # this way multi geometries are handled too
    useflatten <-  FALSE
    grobs <- lapply(1:nrow(data), function(i) {
      row <- data[i, , drop = FALSE]
      gr <- GeomSf$draw_panel(row,
                              panel_params,
                              coord,
                              legend = legend,
                              lineend = lineend,
                              linejoin = linejoin,
                              linemitre = linemitre,
                              na.rm = na.rm)
      if (inherits(gr, "gList")) { # grid v<3.6.0
        useflatten <<- TRUE
        for (i in seq_along(gr)) {
          gr[[i]] <- add_interactive_attrs(gr[[i]], row)
        }
        gr
      } else {
        add_interactive_attrs(gr, row)
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
geom_sf_label_interactive <- function(...)
  layer_interactive(geom_sf_label, ..., interactive_geom = GeomInteractiveLabel)

#' @export
#' @rdname geom_sf_interactive
geom_sf_text_interactive <- function(...)
  layer_interactive(geom_sf_text, ..., interactive_geom = GeomInteractiveText)
