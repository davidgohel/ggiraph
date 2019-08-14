#' @importFrom stats setNames
interactive_sf_grob <-
  function(x,
           lineend = "butt",
           linejoin = "round",
           linemitre = 10) {
    # Need to extract geometry out of corresponding list column
    geometry <- x$geometry
    type <- sf_types[sf::st_geometry_type(geometry)]
    is_point <- type %in% "point"
    type_ind <- match(type, c("point", "line", "other"))
    defaults <- list(
      GeomInteractivePoint$default_aes,
      GeomInteractiveLine$default_aes,
      modify_list(
        GeomInteractivePolygon$default_aes,
        list(fill = "grey90", colour = "grey35")
      )
    )
    default_names <- unique(unlist(lapply(defaults, names)))
    defaults <-
      lapply(stats::setNames(default_names, default_names), function(n) {
        unlist(lapply(defaults, function(def)
          def[[n]] %||% NA))
      })
    alpha <- x$alpha %||% defaults$alpha[type_ind]
    col <- x$colour %||% defaults$colour[type_ind]
    col[is_point] <- alpha(col[is_point], alpha[is_point])
    fill <- x$fill %||% defaults$fill[type_ind]
    fill <- alpha(fill, alpha)
    size <- x$size %||% defaults$size[type_ind]
    stroke <- (x$stroke %||% defaults$stroke[1]) * .stroke / 2
    fontsize <- size * .pt + stroke
    lwd <- ifelse(is_point, stroke, size * .pt)
    pch <- x$shape %||% defaults$shape[type_ind]
    lty <- x$linetype %||% defaults$linetype[type_ind]
    tooltip <- x$tooltip %||% defaults$tooltip[type_ind]
    onclick <- x$onclick %||% defaults$onclick[type_ind]
    data_id <- x$data_id %||% defaults$data_id[type_ind]
    gp <- gpar(
      col = col,
      fill = fill,
      fontsize = fontsize,
      lwd = lwd,
      lty = lty,
      lineend = lineend,
      linejoin = linejoin,
      linemitre = linemitre
    )
    g <- sf::st_as_grob(geometry, pch = pch, gp = gp)
    g <- copy_interactive_attrs(x, g)
    if (is_point[1]) {
      class(g) <- c("interactive_points_grob", class(g))
    } else {
      class(g) <- c("interactive_path_grob", class(g))
    }
    g
  }

sf_types <-
  c(
    GEOMETRY = "other",
    POINT = "point",
    LINESTRING = "line",
    POLYGON = "other",
    MULTIPOINT = "point",
    MULTILINESTRING = "line",
    MULTIPOLYGON = "other",
    GEOMETRYCOLLECTION = "other",
    CIRCULARSTRING = "line",
    COMPOUNDCURVE = "other",
    CURVEPOLYGON = "other",
    MULTICURVE = "other",
    MULTISURFACE = "other",
    CURVE = "other",
    SURFACE = "other",
    POLYHEDRALSURFACE = "other",
    TIN = "other",
    TRIANGLE = "other"
  )
