library(ggiraph)

shinyUI(fluidPage(
  fluidRow(
    column(width=12,
           ggiraphOutput("fixedplot")
     )
  )
))
