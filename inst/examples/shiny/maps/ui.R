library(ggiraph)
library(shiny)
shinyUI(fluidPage(

  titlePanel("Select states on the map"),

  sidebarLayout(
    sidebarPanel(
      uiOutput("seltext")
    ),

    mainPanel(
      girafeOutput("plot")
    )
  )
))
