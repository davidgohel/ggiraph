library(ggplot2)
library(ggiraph)

# geom_line_interactive example -----
if (requireNamespace("dplyr", quietly = TRUE)) {
  gg <- ggplot(
    economics_long,
    aes(
      date,
      value01,
      colour = variable,
      tooltip = variable,
      data_id = variable,
      hover_css = "fill:none;"
    )
  ) +
    geom_line_interactive(size = .75)
  x <- girafe(ggobj = gg)
  x <- girafe_options(x = x, opts_hover(css = "stroke:red;fill:orange"))
  if (interactive()) print(x)
}

# geom_step_interactive example -----
if (requireNamespace("dplyr", quietly = TRUE)) {
  recent <- economics[economics$date > as.Date("2013-01-01"), ]
  gg = ggplot(recent, aes(date, unemploy)) +
    geom_step_interactive(aes(
      tooltip = "Unemployement stairstep line",
      data_id = 1
    ))
  x <- girafe(ggobj = gg)
  x <- girafe_options(x = x, opts_hover(css = "stroke:red;"))
  if (interactive()) print(x)
}

# create datasets -----
id = paste0("id", 1:10)
data = expand.grid(list(
  variable = c("2000", "2005", "2010", "2015"),
  id = id
))
groups = sample(LETTERS[1:3], size = length(id), replace = TRUE)
data$group = groups[match(data$id, id)]
data$value = runif(n = nrow(data))
data$tooltip = paste0('line ', data$id)
data$onclick = paste0("alert(\"", data$id, "\")")

cols = c("orange", "orange1", "orange2", "navajowhite4", "navy")
dataset2 <- data.frame(
  x = rep(1:20, 5),
  y = rnorm(100, 5, .2) + rep(1:5, each = 20),
  z = rep(1:20, 5),
  grp = factor(rep(1:5, each = 20)),
  color = factor(rep(1:5, each = 20)),
  label = rep(paste0("id ", 1:5), each = 20),
  onclick = paste0(
    "alert(\"",
    sample(letters, 100, replace = TRUE),
    "\")"
  )
)


# plots ---
gg_path_1 = ggplot(
  data,
  aes(
    variable,
    value,
    group = id,
    colour = group,
    tooltip = tooltip,
    onclick = onclick,
    data_id = id
  )
) +
  geom_path_interactive(alpha = 0.5)

gg_path_2 = ggplot(
  data,
  aes(variable, value, group = id, data_id = id, tooltip = tooltip)
) +
  geom_path_interactive(alpha = 0.5) +
  facet_wrap(~group)

gg_path_3 = ggplot(dataset2) +
  geom_path_interactive(
    aes(
      x,
      y,
      group = grp,
      data_id = label,
      color = color,
      tooltip = label,
      onclick = onclick
    ),
    size = 1
  )

# ggiraph widgets ---
x <- girafe(ggobj = gg_path_1)
x <- girafe_options(x = x, opts_hover(css = "stroke-width:3px;"))
if (interactive()) {
  print(x)
}

x <- girafe(ggobj = gg_path_2)
x <- girafe_options(x = x, opts_hover(css = "stroke:orange;stroke-width:3px;"))
if (interactive()) {
  print(x)
}

x <- girafe(ggobj = gg_path_3)
x <- girafe_options(x = x, opts_hover(css = "stroke-width:10px;"))
if (interactive()) {
  print(x)
}

m <- ggplot(economics, aes(unemploy / pop, psavert))
p <- m + geom_path_interactive(aes(colour = as.numeric(date), tooltip = date))
x <- girafe(ggobj = p)
if (interactive()) {
  print(x)
}
