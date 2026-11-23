# Trailing comma allowed ----
test_that("Trailing comma allowed", {
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
  expect_s3_class(g, c("ggiraph", "girafe", "htmlwidget"))

})

# girafe, trailing comma ----
test_that("girafe, trailing comma", {
  g <- girafe(ggobj = ggplot(),)
  expect_s3_class(g, c("girafe", "htmlwidget"))
})

# girafe_options, trailing comma ----
test_that("girafe_options, trailing comma", {
  g <- girafe(code = {
    NULL
  })
  expect_identical(girafe_options(g, ), g, info = "no options set")
})
