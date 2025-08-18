library(ggplot2)
library(ggiraph)

dataset <- structure(
  list(
    qsec = c(16.46, 17.02, 18.61, 19.44, 17.02, 20.22),
    disp = c(160, 160, 108, 258, 360, 225),
    carname = c(
      "Mazda RX4",
      "Mazda RX4 Wag",
      "Datsun 710",
      "Hornet 4 Drive",
      "Hornet Sportabout",
      "Valiant"
    ),
    wt = c(2.62, 2.875, 2.32, 3.215, 3.44, 3.46)
  ),
  row.names = c(
    "Mazda RX4",
    "Mazda RX4 Wag",
    "Datsun 710",
    "Hornet 4 Drive",
    "Hornet Sportabout",
    "Valiant"
  ),
  class = "data.frame"
)
dataset

# plots
gg_point = ggplot(data = dataset) +
  geom_point_interactive(aes(
    x = wt,
    y = qsec,
    color = disp,
    tooltip = carname,
    data_id = carname
  )) +
  theme_minimal()

x <- girafe(ggobj = gg_point)
if (interactive()) {
  print(x)
}
