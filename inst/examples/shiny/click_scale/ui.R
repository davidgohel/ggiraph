library(ggiraph)

shinyUI(fluidPage(
  tags$h1("ggiraph key selection demo"),

  fluidRow(
    column(width = 7,
           h4("Select a key in the legend area: "),
           girafeOutput("plot")
    ),
    column(width = 5,
           h4("Selection summary"),
           tableOutput("datatab")
    )
    )
  )
)
