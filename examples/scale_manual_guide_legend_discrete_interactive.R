library(ggplot2)
library(ggiraph)

dat <- data.frame(
  name = c("Guy", "Ginette", "David", "Cedric", "Frederic"),
  gender = c("Male", "Female", "Male", "Male", "Male"),
  height = c(169, 160, 171, 172, 171)
)
p <- ggplot(dat, aes(x = name, y = height, fill = gender, data_id = name)) +
  geom_bar_interactive(stat = "identity")

# add interactive scale (guide is legend)
p1 <- p +
  scale_fill_manual_interactive(
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = c(Female = "Female", Male = "Male"),
    tooltip = c(Male = "Male", Female = "Female")
  )
x <- girafe(ggobj = p1)
if (interactive()) {
  print(x)
}

# make the title interactive too
p2 <- p +
  scale_fill_manual_interactive(
    name = label_interactive(
      "gender",
      tooltip = "Gender levels",
      data_id = "legend.title"
    ),
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = c(Female = "Female", Male = "Male"),
    tooltip = c(Male = "Male", Female = "Female")
  )
x <- girafe(ggobj = p2)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}

# the interactive params can be functions too
p3 <- p +
  scale_fill_manual_interactive(
    name = label_interactive(
      "gender",
      tooltip = "Gender levels",
      data_id = "legend.title"
    ),
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = function(breaks) {
      as.character(breaks)
    },
    tooltip = function(breaks) {
      as.character(breaks)
    },
    onclick = function(breaks) {
      paste0("alert(\"", as.character(breaks), "\")")
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
  scale_fill_manual_interactive(
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = function(breaks) {
      as.character(breaks)
    },
    tooltip = function(breaks) {
      as.character(breaks)
    },
    onclick = function(breaks) {
      paste0("alert(\"", as.character(breaks), "\")")
    },
    guide = guide_legend_interactive(
      title.theme = element_text_interactive(
        size = 8,
        data_id = "legend.title",
        onclick = "alert(\"Gender levels\")",
        tooltip = "Gender levels"
      ),
      label.theme = element_text_interactive(
        size = 8
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

# make the legend labels interactive
p5 <- p +
  scale_fill_manual_interactive(
    name = label_interactive(
      "gender",
      tooltip = "Gender levels",
      data_id = "legend.title"
    ),
    values = c(Male = "#0072B2", Female = "#009E73"),
    data_id = function(breaks) {
      as.character(breaks)
    },
    tooltip = function(breaks) {
      as.character(breaks)
    },
    onclick = function(breaks) {
      paste0("alert(\"", as.character(breaks), "\")")
    },
    labels = function(breaks) {
      lapply(breaks, function(br) {
        label_interactive(
          as.character(br),
          data_id = as.character(br),
          onclick = paste0("alert(\"", as.character(br), "\")"),
          tooltip = as.character(br)
        )
      })
    }
  )
x <- girafe(ggobj = p5)
x <- girafe_options(
  x,
  opts_hover_key(girafe_css("stroke:red", text = "stroke:none;fill:red"))
)
if (interactive()) {
  print(x)
}
