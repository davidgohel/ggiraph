library(ggiraph)
shinyUI(fluidPage(
  fluidRow(
    column(
      width=6,offset = 3,
      textInput("selpoint", label = "Selected species"),
      ggiraphOutput("plot")
    )
  )
))
