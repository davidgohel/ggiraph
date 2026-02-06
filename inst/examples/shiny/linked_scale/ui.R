library(ggiraph)

shinyUI(fluidPage(
  tags$h1("ggiraph key selection demo"),

  fluidRow(
    column(width = 7,
           h4("Click a legend key or a point to select: "),
           girafeOutput("plot")
    ),
    column(width = 5,
           h4("Selection summary"),
           tableOutput("datatab")
    )
    )
  )
)
