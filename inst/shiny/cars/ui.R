library(ggiraph)
shinyUI(fluidPage(
  sidebarLayout(

    sidebarPanel(
      textInput("title", label = "Title", placeholder = "type graph title"),
      div(id = "log")
    ),

    mainPanel(
      ggiraphOutput("plot")
    )
  )
))
