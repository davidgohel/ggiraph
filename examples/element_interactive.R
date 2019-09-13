library(ggplot2)
library(ggiraph)

dataset <- structure(list(qsec = c(16.46, 17.02, 18.61, 19.44, 17.02, 20.22
), disp = c(160, 160, 108, 258, 360, 225), carname = c("Mazda RX4",
"Mazda RX4 Wag", "Datsun 710", "Hornet 4 Drive", "Hornet Sportabout",
"Valiant"), wt = c(2.62, 2.875, 2.32, 3.215, 3.44, 3.46)), row.names = c("Mazda RX4",
"Mazda RX4 Wag", "Datsun 710", "Hornet 4 Drive", "Hornet Sportabout",
"Valiant"), class = "data.frame")

# plots
gg_point = ggplot(data = dataset) +
  geom_point_interactive(aes(
    x = wt,
    y = qsec,
    color = disp,
    tooltip = carname,
    data_id = carname
  )) +
  theme_minimal() +
  theme(
    plot.title = element_text_interactive(
      data_id = "plot.title",
      tooltip = "plot title",
      hover_css = "fill:red;stroke:none;font-size:12pt"
    ),
    plot.subtitle = element_text_interactive(
      data_id = "plot.subtitle",
      tooltip = "plot subtitle",
      hover_css = "fill:none;"
    ),
    axis.title.x = element_text_interactive(
      data_id = "axis.title.x",
      tooltip = "Description for x axis",
      hover_css = "fill:red;stroke:none;"
    ),
    axis.title.y = element_text_interactive(
      data_id = "axis.title.y",
      tooltip = "Description for y axis",
      hover_css = "fill:red;stroke:none;"
    ),
    panel.grid.major = element_line_interactive(
      data_id = "panel.grid",
      tooltip = "Major grid lines",
      hover_css = "fill:none;stroke:red;"
    )
  ) +
  labs(
    title = "Interactive points example!",
    subtitle = label_interactive(
      "by ggiraph",
      tooltip = "Click me!",
      onclick = "window.open(\"https://davidgohel.github.io/ggiraph/\")",
      hover_css = "fill:magenta;cursor:pointer;"
    )
  )

x <- girafe(ggobj = gg_point)
if( interactive() ) print(x)
