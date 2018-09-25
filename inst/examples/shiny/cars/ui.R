library(ggiraph)
shinyUI(fluidPage(
  sidebarLayout(

    sidebarPanel(
      textInput("selpoint", label = "Selected point")
    ),

    mainPanel(
      girafeOutput("plot")
    )
  )
))