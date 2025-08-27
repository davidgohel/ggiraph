library(ggplot2)
library(ggiraph)

## original code: see section examples of ggplot2::geom_sf help file
if (
  requireNamespace(
    "sf",
    quietly = TRUE,
    versionCheck = list(op = ">=", version = "0.7-3")
  )
) {
  nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
  gg <- ggplot(nc) +
    geom_sf_interactive(aes(fill = AREA, tooltip = NAME, data_id = NAME))
  x <- girafe(ggobj = gg)
  if (interactive()) {
    print(x)
  }

  nc_3857 <- sf::st_transform(nc, 3857)

  # Unfortunately if you plot other types of feature you'll need to use
  # show.legend to tell ggplot2 what type of legend to use
  nc_3857$mid <- sf::st_centroid(nc_3857$geometry)
  gg <- ggplot(nc_3857) +
    geom_sf(colour = "white") +
    geom_sf_interactive(
      aes(geometry = mid, size = AREA, tooltip = NAME, data_id = NAME),
      show.legend = "point"
    )
  x <- girafe(ggobj = gg)
  if (interactive()) {
    print(x)
  }

  # Example with texts.
  gg <- ggplot(nc_3857[1:3, ]) +
    geom_sf(aes(fill = AREA)) +
    geom_sf_text_interactive(aes(label = NAME, tooltip = NAME), color = "white")
  x <- girafe(ggobj = gg)
  if (interactive()) {
    print(x)
  }

  # Example with labels.
  gg <- ggplot(nc_3857[1:3, ]) +
    geom_sf(aes(fill = AREA)) +
    geom_sf_label_interactive(aes(label = NAME, tooltip = NAME))
  x <- girafe(ggobj = gg)
  if (interactive()) print(x)
}
