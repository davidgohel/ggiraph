library(ggiraph)
shinyUI(fluidPage(
  fluidRow(

    column(width = 12,
      uiOutput("selpoint", style = "text-align:center;padding:4pt;"),
      girafeOutput("plot")
    )
  )
))
