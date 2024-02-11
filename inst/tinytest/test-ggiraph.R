library(tinytest)
library(ggiraph)
library(ggplot2)
library(xml2)

# ggiraph ----
{
  g <- ggiraph(code = print(ggplot()))
  expect_inherits(g, c("ggiraph", "girafe", "htmlwidget"))

  expect_warning(ggiraph(code = print(ggplot()), dep_dir = "foo"))
}

# ggiraphOutput ----
{
  result <- girafeOutput("foo")
  expect_inherits(result, "shiny.tag.list")
}

if (requireNamespace("httpuv", quietly = TRUE)) {
  # renderggiraph ----
  {
    result <- renderGirafe(ggiraph({
      print(ggplot())
    }))
    expect_inherits(result, "shiny.render.function")
  }
}
