library(ggiraph)
shinyUI(fluidPage(
  fluidRow(
    column(
      width=6,offset = 3,
      uiOutput("selpoint"),
      girafeOutput("plot")
    )
  )
))
