library(ggiraph)
library(shiny)
shinyUI(fluidPage(

  titlePanel("Select states on the map"),

  sidebarLayout(
    sidebarPanel(
      textInput("sel", label = "Selected states")
    ),

    mainPanel(
      ggiraphOutput("plot")
    )
  )
))
