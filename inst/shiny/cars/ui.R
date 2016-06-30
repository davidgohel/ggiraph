library(ggiraph)
shinyUI(fluidPage(
  sidebarLayout(

    sidebarPanel(
      textInput("title", label = "Title"),
      div(id = "log")
    ),

    mainPanel(
      ggiraphOutput("plot")
    )
  )
))
