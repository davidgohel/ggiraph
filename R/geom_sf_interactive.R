default_aesthetics <- function(type) {
  if (type == "point") {
    GeomInteractivePoint$default_aes
  } else if (type == "line") {
    GeomInteractiveLine$default_aes
  } else  {
    utils::modifyList(GeomInteractivePolygon$default_aes, list(fill = "grey90", colour = "grey35"))
  }
}

interactive_sf_grob <- function(row) {
  # Need to extract geometry out of corresponding list column
  geometry <- row$geometry[[1]]

  if (inherits(geometry, c("POINT", "MULTIPOINT"))) {
    row <- utils::modifyList(default_aesthetics("point"), row)
    gp <- gpar(
      col = alpha(row$colour, row$alpha),
      fill = alpha(row$fill, row$alpha),
      # Stroke is added around the outside of the point
      fontsize = row$size * .pt + row$stroke * .stroke / 2,
      lwd = row$stroke * .stroke / 2
    )

    zz <- sf::st_as_grob(geometry, gp = gp, pch = row$shape)

    if (!is.null(row$tooltip))
      zz$tooltip <- rep(row$tooltip, length(zz$x))
    if (!is.null(row$onclick))
      zz$onclick <- rep(row$onclick, length(zz$x))
    if (!is.null(row$data_id))
      zz$data_id <- rep(row$data_id, length(zz$x))

    class(zz) <- c("interactive_points_grob", class(zz))
    zz
  } else {
    row <- utils::modifyList(default_aesthetics("poly"), row)
    gp <- gpar(
      col = row$colour,
      fill = alpha(row$fill, row$alpha),
      lwd = row$size * .pt,
      lty = row$linetype,
      lineend = "butt"
    )

    zz <- sf::st_as_grob(geometry, gp = gp)
    if (!is.null(row$tooltip))
      zz$tooltip <- rep(row$tooltip, length(zz$x))
    if (!is.null(row$onclick))
      zz$onclick <- rep(row$onclick, length(zz$x))
    if (!is.null(row$data_id))
      zz$data_id <- rep(row$data_id, length(zz$x))

    class(zz) <- c("interactive_path_grob", class(zz))

    zz
  }
}

# GeomInteractiveSf -----
#' @importFrom ggplot2 coord_sf
GeomInteractiveSf <- ggproto("GeomInteractiveSf", Geom,
                             required_aes = "geometry",
                             default_aes = aes(
                               shape = NULL,
                               colour = NULL,
                               fill = NULL,
                               size = NULL,
                               linetype = 1,
                               alpha = NA,
                               stroke = 0.5,
                               tooltip = NULL, onclick = NULL, data_id = NULL
                             ),

                             draw_panel = function(data, panel_params, coord, legend = NULL) {
                               if (!inherits(coord, "CoordSf")) {
                                 stop("geom_sf() must be used with coord_sf()", call. = FALSE)
                               }

                               # Need to refactor this to generate one grob per geometry type
                               coord <- coord$transform(data, panel_params)
                               if( !is.null(coord$tooltip) && !is.character(coord$tooltip) )
                                 coord$tooltip <- as.character(coord$tooltip)
                               if( !is.null(coord$onclick) && !is.character(coord$onclick) )
                                 coord$onclick <- as.character(coord$onclick)
                               if( !is.null(coord$data_id) && !is.character(coord$data_id) )
                                 coord$data_id <- as.character(coord$data_id)


                               grobs <- lapply(1:nrow(data), function(i) {
                                 interactive_sf_grob(coord[i, , drop = FALSE])
                               })
                               do.call("gList", grobs)
                             },

                             draw_key = function(data, params, size) {
                               data <- utils::modifyList(default_aesthetics(params$legend), data)
                               if (params$legend == "point") {
                                 draw_key_point(data, params, size)
                               } else if (params$legend == "line") {
                                 draw_key_path(data, params, size)
                               } else {
                                 draw_key_polygon(data, params, size)
                               }
                             }
)

# geom_sf_interactive -----

#' @title interactive sf objects
#'
#' @description
#' The geometry is based on \code{\link[ggplot2]{ggsf}}.
#' See the documentation for those functions for more details.
#'
#' @seealso \code{\link{ggiraph}}
#' @inheritParams geom_point_interactive
#' @examples
#' # add interactive sf objects to a ggplot -------
#' @example examples/geom_sf_interactive.R
#' @export
geom_sf_interactive <- function(mapping = aes(), data = NULL, stat = "sf",
                                position = "identity", na.rm = FALSE, show.legend = NA,
                                inherit.aes = TRUE, ...) {

  # Automatically determin name of geometry column
  if (!is.null(data) && inherits(data, "sf")) {
    geometry_col <- attr(data, "sf_column")
  } else {
    geometry_col <- "geometry"
  }
  if (is.null(mapping$geometry)) {
    mapping$geometry <- as.name(geometry_col)
  }

  c(
    layer(
      geom = GeomInteractiveSf,
      data = data,
      mapping = mapping,
      stat = stat,
      position = position,
      show.legend = if (is.character(show.legend)) TRUE else show.legend,
      inherit.aes = inherit.aes,
      params = list(
        na.rm = na.rm,
        legend = if (is.character(show.legend)) show.legend else "polygon",
        ...
      )
    ),
    coord_sf(default = TRUE)
  )
}

