library(ggiraph)
shinyUI(fluidPage(
  fluidRow(
    column(
      width=12,
      textInput("selpoint", label = "Selected species"),
      ggiraphOutput("plot")
    )
  )
))
