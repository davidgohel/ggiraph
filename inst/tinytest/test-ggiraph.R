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
  result <- ggiraphOutput("foo")
  expect_inherits(result, "shiny.tag.list")
}

# renderggiraph ----
{
  result <- renderggiraph(ggiraph({
    print(ggplot())
  }))
  expect_inherits(result, "shiny.render.function")
}
