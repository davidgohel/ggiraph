library(ggiraph)
library(shiny)
shinyUI(fluidPage(

  fluidRow(

    column(width = 3, uiOutput("seltext")),
    column(width = 9, girafeOutput("plot"))
  )

))
