library(tinytest)
library(ggiraph)
library(ggplot2)


# Trailing comma allowed ----
{
  p <- diamonds |>
    ggplot() +
    geom_bar_interactive(
      mapping = aes(
        x = color,
        fill = color,
      ),
    ) +
    scale_fill_discrete_interactive(
      guide = guide_legend_interactive(
        title = "Color",
        position = "bottom",
      ),
    ) +
    facet_wrap_interactive(vars(cut), ) +
    annotate_interactive("text", x = "E", y = 1, label = "E", color = "red", vjust = "bottom", ) +
    labs(
      title = label_interactive("Title",)
    ) +
    theme(
      plot.title = element_text_interactive(tooltip = "Plot title",)
    )

  g <- girafe(code = print(p))
  expect_inherits(g, c("ggiraph", "girafe", "htmlwidget"))

}

# girafe, trailing comma ----
{
  g <- girafe(ggobj = ggplot(),)
  expect_inherits(g, c("girafe", "htmlwidget"))
}

# girafe_options, trailing comma ----
{
  g <- girafe({
    NULL
  })
  expect_identical(girafe_options(g, ), g, info = "no options set")
}
