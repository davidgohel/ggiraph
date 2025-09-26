library(ggplot2)
library(ggiraph)

# geom_text_repel_interactive
if (
  requireNamespace("ggbeeswarm", quietly = TRUE) &&
    requireNamespace("dplyr", quietly = TRUE)
) {
  set.seed(2)

  dat <- dplyr::filter(
    .data = diamonds,
    cut %in% c("Fair", "Good"),
    color %in% c("D", "E", "H")
  )
  dat <- dplyr::sample_n(tbl = dat, 150)

  dodge_width <- .8
  position <- position_dodge(width = dodge_width)

  gg_qr <- ggplot(dat, aes(x = cut, y = y, fill = color)) +
    geom_violin(
      alpha = .5,
      width = dodge_width
    ) +
    geom_boxplot(position = position, alpha = .5, outliers = FALSE) +
    geom_quasirandom_interactive(
      aes(tooltip = y, data_id = color),
      shape = 21,
      size = 2,
      dodge.width = dodge_width,
      color = "black",
      alpha = .5
    ) +
    theme_minimal()

  x <- girafe(ggobj = gg_qr)
  x <- girafe_options(x = x, opts_hover(css = "fill:#FF4C3B;"))
  if (interactive()) print(x)




  dat <- mtcars
  dat$name <- row.names(mtcars)
  dat$am <- factor(dat$am)
  dat$gear <- factor(dat$gear)

  dodge_width <- .8
  position <- position_dodge(width = dodge_width)

  gg_qr <- ggplot(dat, aes(x = am, y = disp, fill = gear, group = interaction(am, gear))) +
    geom_quasirandom_interactive(
      aes(tooltip = disp, data_id = name),
      shape = 21,
      size = 2,
      dodge.width = dodge_width,
      color = "black"
    ) +
    scale_fill_manual_interactive(
      name = label_interactive(
        "Gearrrrrr",
        tooltip = "Gearrrrrr",
        data_id = "gear"
      ),
      values = c("3" = "#0072B2", "4" = "#009E73", "5" = "red"),
      data_id = c("3" = "tree", "4" = "tree", "5" = "four"),
      tooltip = c("3" = "tree", "4" = "tree", "5" = "four")
    ) +
    theme_minimal()

  x <- girafe(ggobj = gg_qr)
  if (interactive()) print(x)
}
