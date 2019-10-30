library(ggiraph)
shinyUI(fluidPage(
  sidebarLayout(

    sidebarPanel(
      uiOutput("selpoint")
    ),

    mainPanel(
      girafeOutput("plot")
    )
  )
))
