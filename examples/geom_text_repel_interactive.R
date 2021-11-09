library(ggplot2)
library(ggiraph)

# geom_text_repel_interactive
if (requireNamespace("ggrepel", quietly = TRUE)) {
  dataset = mtcars
  dataset$label = row.names(mtcars)
  dataset$tooltip = paste0(dataset$label, "<br/>", "cyl: ", dataset$cyl, "<br/>",
                           "gear: ", dataset$gear, "<br/>",
                           "carb: ", dataset$carb)
  p <- ggplot(dataset, aes(wt, mpg, color = qsec ) ) +
    geom_point_interactive(aes(tooltip = tooltip, data_id = label))

  gg_text = p +
    geom_text_repel_interactive(
      aes(label = label, tooltip = tooltip, data_id = label),
      size = 3
    )

  x <- girafe(ggobj = gg_text)
  x <- girafe_options(x = x,
                      opts_hover(css = "fill:#FF4C3B;") )
  if (interactive()) print(x)
}

# geom_label_repel_interactive
if (requireNamespace("ggrepel", quietly = TRUE)) {
  gg_label = p +
    geom_label_repel_interactive(
      aes(label = label, tooltip = tooltip, data_id = label),
      size = 3,
      max.overlaps = 12
    )

  x2 <- girafe(ggobj = gg_label)
  x2 <- girafe_options(x = x2,
                      opts_hover(css = ggiraph::girafe_css(
                       css = ";",
                       area = "fill:#FF4C3B;"
                      )) )
  if (interactive()) print(x2)
}
