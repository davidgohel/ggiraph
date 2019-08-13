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

