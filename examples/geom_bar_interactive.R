library(ggplot2)
library(ggiraph)
library(gdtools)

register_liberationsans()

p <- ggplot(mpg, aes(x = class, tooltip = class, data_id = class)) +
  geom_bar_interactive() +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

x <- girafe(
  ggobj = p,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}

dat <- data.frame(
  name = c("David", "Constance", "Leonie"),
  gender = c("Male", "Female", "Female"),
  height = c(172, 159, 71)
)
p <- ggplot(dat, aes(x = name, y = height, tooltip = gender, data_id = name)) +
  geom_col_interactive() +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)

x <- girafe(
  ggobj = p,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}

# an example with interactive guide ----
dat <- data.frame(
  name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
  gender = c("Male", "Female", "Male", "Male", "Male"),
  height = c(169, 160, 171, 172, 171)
)
p <- ggplot(dat, aes(x = name, y = height, fill = gender, data_id = name)) +
  geom_bar_interactive(stat = "identity") +
  scale_fill_manual_interactive(
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = c(Female = "Female", Male = "Male"),
    tooltip = c(Male = "Male", Female = "Female")
  ) +
  theme_minimal(base_family = "Liberation Sans", base_size = 11)
x <- girafe(
  ggobj = p,
  dependencies = list(
    liberationsansHtmlDependency()
  )
)
if (interactive()) {
  print(x)
}
