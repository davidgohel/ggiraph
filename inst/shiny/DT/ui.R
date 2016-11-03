library(ggiraph)
library(htmltools)
shinyUI(fluidPage(

  fluidRow(
    column(width=12,
      includeScript(path = "set_search_val.js"),
      h4("click a point, the data table will be filtered..."),
      ggiraphOutput("plot_"),
      DT::dataTableOutput("dt_")
    )
  )
))
