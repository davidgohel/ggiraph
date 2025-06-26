library(ggplot2)
library(ggiraph)

p <- ggplot(mpg, aes(x = class, y = hwy, tooltip = class)) +
  geom_boxplot_interactive()

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}

p <- ggplot(mpg) +
  geom_boxplot_interactive(
    aes(
      x = drv,
      y = hwy,
      fill = class,
      data_id = class,
      tooltip = after_stat({
        paste0(
          "class: ",
          .data$fill,
          "\nQ1: ",
          prettyNum(.data$lower),
          "\nQ3: ",
          prettyNum(.data$upper),
          "\nmedian: ",
          prettyNum(.data$middle)
        )
      })
    ),
    outlier.colour = "red"
  ) +
  guides(fill = "none") +
  theme_minimal()

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}


p <- ggplot(mpg) +
  geom_boxplot_interactive(
    aes(
      x = drv,
      y = hwy,
      fill = class,
      group = paste(drv, class),
      data_id = class,
      tooltip = after_stat({
        paste0(
          "class: ",
          .data$fill,
          "\nQ1: ",
          prettyNum(.data$lower),
          "\nQ3: ",
          prettyNum(.data$upper),
          "\nmedian: ",
          prettyNum(.data$middle)
        )
      }),
      outlier.tooltip = paste(
        "I am an outlier!\nhwy:",
        hwy,
        "\ndrv:",
        drv,
        "\nclass:",
        class
      )
    ),
    outlier.colour = "red"
  ) +
  guides(fill = "none") +
  theme_minimal()

x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
