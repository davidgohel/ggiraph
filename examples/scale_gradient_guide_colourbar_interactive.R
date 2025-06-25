library(ggplot2)
library(ggiraph)

df <- expand.grid(x = 0:5, y = 0:5)
df$z <- runif(nrow(df))

p <- ggplot(df, aes(x, y, fill = z, tooltip = "tooltip")) +
  geom_raster_interactive()

# add an interactive scale (guide is colourbar)
p1 <- p +
  scale_fill_gradient_interactive(
    data_id = "colourbar",
    onclick = "alert(\"colourbar\")",
    tooltip = "colourbar"
  )
x <- girafe(ggobj = p1)
if (interactive()) {
  print(x)
}

# make the legend title interactive
p2 <- p +
  scale_fill_gradient_interactive(
    data_id = "colourbar",
    onclick = "alert(\"colourbar\")",
    tooltip = "colourbar",
    name = label_interactive(
      "z",
      data_id = "colourbar",
      onclick = "alert(\"colourbar\")",
      tooltip = "colourbar"
    )
  )
x <- girafe(ggobj = p2)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}

# make the legend labels interactive
p3 <- p +
  scale_fill_gradient_interactive(
    data_id = "colourbar",
    onclick = "alert(\"colourbar\")",
    tooltip = "colourbar",
    name = label_interactive(
      "z",
      data_id = "colourbar",
      onclick = "alert(\"colourbar\")",
      tooltip = "colourbar"
    ),
    labels = function(breaks) {
      lapply(breaks, function(abreak) {
        label_interactive(
          as.character(abreak),
          data_id = paste0("colourbar", abreak),
          onclick = "alert(\"colourbar\")",
          tooltip = paste0("colourbar", abreak)
        )
      })
    }
  )
x <- girafe(ggobj = p3)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}

# also via the guide
p4 <- p +
  scale_fill_gradient_interactive(
    data_id = "colourbar",
    onclick = "alert(\"colourbar\")",
    tooltip = "colourbar",
    guide = guide_colourbar_interactive(
      title.theme = element_text_interactive(
        size = 8,
        data_id = "colourbar",
        onclick = "alert(\"colourbar\")",
        tooltip = "colourbar"
      ),
      label.theme = element_text_interactive(
        size = 8,
        data_id = "colourbar",
        onclick = "alert(\"colourbar\")",
        tooltip = "colourbar"
      )
    )
  )
x <- girafe(ggobj = p4)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}

# make the legend background interactive
p5 <- p4 +
  theme(
    legend.background = element_rect_interactive(
      data_id = "colourbar",
      onclick = "alert(\"colourbar\")",
      tooltip = "colourbar"
    )
  )
x <- girafe(ggobj = p5)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}
