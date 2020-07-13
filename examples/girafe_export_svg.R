library(ggplot2)
library(ggiraph)
library(htmltools)

df <- mtcars
df$id <- rownames(mtcars)
p <- ggplot(df, aes(wt, mpg)) +
  geom_point_interactive(aes(tooltip = id, data_id = id), size = 5)
x <- girafe(
  ggobj = p,
  width_svg = 7,
  height_svg = 7,
  options = list(
    opts_zoom(min = 1, max = 4),
    opts_toolbar(saveaspng = TRUE),
    opts_hover(css = "fill:magenta;"),
    opts_hover_inv(css = "opacity:.3"),
    opts_selection(only_shiny = FALSE, css = "fill:red;"),
    opts_sizing(rescale = FALSE)
  )
)
workdir <- tempfile(pattern = "ggiraph")
dir.create(workdir)
svgfilename <- file.path(workdir, "test.svg")
girafe_export_svg(x, svgfilename, TRUE)
message("Exported SVG: ", svgfilename)

if (interactive()) {
  html <- tagList(
    tags$head(tags$title("ggiraph interactive standalone SVG")),
    tags$body(
      tags$p("This is an embedded standalone interactive svg"),
      tags$embed(
        type = "image/svg+xml",
        src = "test.svg"
      ),
      tags$div(
        tags$a(href = "test.svg", target = "_blank", "Click to open the svg in another tab")
      )
    )
  )
  htmlfilename <- file.path(workdir, "test.html")
  htmltools::save_html(
    html = html,
    file = htmlfilename
  )
  message("Exported HTML: ", htmlfilename)
  browseURL(htmlfilename)
} else {
  unlink(workdir, recursive = TRUE)
}
